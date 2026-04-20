package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var (
	styleSelected = lipgloss.NewStyle().Bold(true)
	styleMarked   = lipgloss.NewStyle().Foreground(lipgloss.Color("212"))
	styleHelp     = lipgloss.NewStyle().Foreground(lipgloss.Color("241"))
	styleDone     = lipgloss.NewStyle().Foreground(lipgloss.Color("78"))
)

type script struct {
	filename    string // e.g. run_onchange_01-install-packages.sh.tmpl
	display     string // e.g. 01-install-packages
	rendered    string // e.g. 01-install-packages.sh (as shown in chezmoi diff)
	fullPath    string
}

type model struct {
	scripts     []script
	cursor      int
	pending     map[int]bool
	message     string
	quitting    bool
	applyOnExit bool
}

func main() {
	scripts, err := findScripts()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	if len(scripts) == 0 {
		fmt.Println("No run_onchange scripts found.")
		return
	}

	// Handle pattern mode from CLI args
	if len(os.Args) > 1 {
		pattern := os.Args[1]
		found := false
		for _, s := range scripts {
			if strings.Contains(s.display, pattern) {
				if err := markForRerun(s.fullPath); err != nil {
					fmt.Fprintf(os.Stderr, "Error marking %s: %v\n", s.display, err)
					continue
				}
				fmt.Printf("Marked: %s\n", s.display)
				found = true
			}
		}
		if !found {
			fmt.Fprintf(os.Stderr, "No scripts matching '%s' found.\n", pattern)
			os.Exit(1)
		}
		fmt.Println("Run 'chezmoi apply' to execute.")
		return
	}

	pending := getPending(scripts)
	m := model{
		scripts: scripts,
		pending: pending,
	}

	p := tea.NewProgram(m)
	finalModel, err := p.Run()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	if fm, ok := finalModel.(model); ok && fm.applyOnExit {
		cmd := exec.Command("chezmoi", "apply")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Stdin = os.Stdin
		if err := cmd.Run(); err != nil {
			fmt.Fprintf(os.Stderr, "chezmoi apply failed: %v\n", err)
			os.Exit(1)
		}
	}
}

func findScripts() ([]script, error) {
	out, err := exec.Command("chezmoi", "source-path").Output()
	if err != nil {
		return nil, fmt.Errorf("chezmoi source-path: %w", err)
	}
	scriptsDir := filepath.Join(strings.TrimSpace(string(out)), ".chezmoiscripts")

	entries, err := os.ReadDir(scriptsDir)
	if err != nil {
		return nil, fmt.Errorf("reading %s: %w", scriptsDir, err)
	}

	var scripts []script
	for _, e := range entries {
		name := e.Name()
		if !strings.HasPrefix(name, "run_onchange_") {
			continue
		}

		display := name
		display = strings.TrimPrefix(display, "run_onchange_after_")
		display = strings.TrimPrefix(display, "run_onchange_")
		display = strings.TrimSuffix(display, ".sh.tmpl")
		display = strings.TrimSuffix(display, ".sh")

		rendered := name
		rendered = strings.TrimSuffix(rendered, ".tmpl")
		rendered = strings.TrimPrefix(rendered, "run_onchange_after_")
		rendered = strings.TrimPrefix(rendered, "run_onchange_")
		rendered = strings.TrimPrefix(rendered, "run_after_")
		rendered = strings.TrimPrefix(rendered, "run_once_")

		scripts = append(scripts, script{
			filename: name,
			display:  display,
			rendered: rendered,
			fullPath: filepath.Join(scriptsDir, name),
		})
	}

	sort.Slice(scripts, func(i, j int) bool {
		return scripts[i].filename < scripts[j].filename
	})

	return scripts, nil
}

func getPending(scripts []script) map[int]bool {
	pending := make(map[int]bool)
	out, err := exec.Command("chezmoi", "diff", "--no-pager").CombinedOutput()
	if err != nil {
		return pending
	}
	// Strip ANSI codes
	diff := stripAnsi(string(out))
	for i, s := range scripts {
		if strings.Contains(diff, "chezmoiscripts/"+s.rendered) {
			pending[i] = true
		}
	}
	return pending
}

func stripAnsi(s string) string {
	var result strings.Builder
	i := 0
	for i < len(s) {
		if s[i] == '\x1b' && i+1 < len(s) && s[i+1] == '[' {
			j := i + 2
			for j < len(s) && !((s[j] >= 'A' && s[j] <= 'Z') || (s[j] >= 'a' && s[j] <= 'z')) {
				j++
			}
			if j < len(s) {
				j++ // skip the final letter
			}
			i = j
		} else {
			result.WriteByte(s[i])
			i++
		}
	}
	return result.String()
}

func markForRerun(path string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	hash := randomHash()
	lines := strings.Split(string(data), "\n")

	found := false
	for i, line := range lines {
		if strings.HasPrefix(line, "# rerun:") {
			lines[i] = "# rerun: " + hash
			found = true
			break
		}
	}

	if !found {
		// Ensure trailing newline before appending
		if len(lines) > 0 && lines[len(lines)-1] == "" {
			lines = append(lines[:len(lines)-1], "# rerun: "+hash, "")
		} else {
			lines = append(lines, "# rerun: "+hash)
		}
	}

	return os.WriteFile(path, []byte(strings.Join(lines, "\n")), 0644)
}

func unmarkRerun(path string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	lines := strings.Split(string(data), "\n")
	var newLines []string
	for _, line := range lines {
		if !strings.HasPrefix(line, "# rerun:") {
			newLines = append(newLines, line)
		}
	}

	return os.WriteFile(path, []byte(strings.Join(newLines, "\n")), 0644)
}

func randomHash() string {
	b := make([]byte, 4)
	rand.Read(b)
	return hex.EncodeToString(b)
}

// --- Bubbletea model ---

type pendingMsg map[int]bool
func refreshPending(scripts []script) tea.Cmd {
	return func() tea.Msg {
		return pendingMsg(getPending(scripts))
	}
}


func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "q", "ctrl+c":
			m.quitting = true
			return m, tea.Quit
		case "up", "k":
			if m.cursor > 0 {
				m.cursor--
			}
		case "down", "j":
			if m.cursor < len(m.scripts)-1 {
				m.cursor++
			}
		case " ":
			s := m.scripts[m.cursor]
			if m.pending[m.cursor] {
				unmarkRerun(s.fullPath)
				m.message = fmt.Sprintf("Unmarked: %s", s.display)
			} else {
				markForRerun(s.fullPath)
				m.message = fmt.Sprintf("Marked: %s", s.display)
			}
			return m, refreshPending(m.scripts)
		case "a":
			hasPending := false
			for _, v := range m.pending {
				if v {
					hasPending = true
					break
				}
			}
			if !hasPending {
				m.message = "Nothing marked to run."
				return m, nil
			}
			m.applyOnExit = true
			m.quitting = true
			return m, tea.Quit
		}
	case pendingMsg:
		m.pending = map[int]bool(msg)
	}
	return m, nil
}

func (m model) View() string {
	if m.quitting {
		return ""
	}

	var b strings.Builder

	b.WriteString("Chezmoi onchange scripts\n")
	b.WriteString(styleHelp.Render("  ↑/↓/j/k navigate · space toggle · a apply · q quit"))
	b.WriteString("\n\n")

	for i, s := range m.scripts {
		cursor := "  "
		if i == m.cursor {
			cursor = "> "
		}

		marker := "  "
		if m.pending[i] {
			marker = "* "
		}

		line := fmt.Sprintf("%s%s%s", cursor, marker, s.display)
		if i == m.cursor {
			line = styleSelected.Render(line)
		} else if m.pending[i] {
			line = styleMarked.Render(line)
		}

		b.WriteString(line)
		b.WriteString("\n")
	}

	if m.message != "" {
		b.WriteString("\n")
		b.WriteString(styleDone.Render(m.message))
		b.WriteString("\n")
	}

	return b.String()
}
