// "haxx". A nonsense hacking generator.
// Gives you a bollywood experience right into your terminal, with
// * More than 1000 ips simulated!
// * An INFINITE amount of simulated names!
// * Over 100 different types of glitches!
// * An overly dramatic hack, just like seen in the movies!
// * And more (If you -REALLY- have a lot of time to spend staring at this command.)
// Compile this with "gcc haxx.c -o haxx -static (-Bstatic if you are on MacOS) -O3 -Wall"
// And if you really hate yourself, just send it to its appropriate directory with "sudo mv haxx /usr/local/bin/."
// And then run it by typing haxx.
// And grab the popcorn.
// Screenshot: https://i.imgur.com/W30hsmW.png

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

char current_hack_message[30] = "HACKING MAINFRAME...";

void clear_screen() {
    printf("\033[2J\033[H");
    fflush(stdout);
}

void print_random_ip(int glitch, int surprise_glitch, int *is_6666, int test_mode) {
    int ip1 = test_mode ? 6 : rand() % 256;
    int ip2 = test_mode ? 6 : rand() % 256;
    int ip3 = test_mode ? 6 : rand() % 256;
    int ip4 = test_mode ? 6 : rand() % 256;
    char ip[16];
    snprintf(ip, sizeof(ip), "%d.%d.%d.%d", ip1, ip2, ip3, ip4);
    *is_6666 = (ip1 == 6 && ip2 == 6 && ip3 == 6 && ip4 == 6);
    if (surprise_glitch) {
        for (int i = 0; ip[i] != '\0' && i < 15; i++) {
            if (rand() % 3 == 0) {
                int effect = rand() % 3;
                if (effect == 0) {
                    char emojis[] = "😈🔥💾";
                    printf("\033[5;31m%c\033[0m", emojis[rand() % 3]);
                } else if (effect == 1) {
                    printf("\033[90m%c\033[0m", ip[i]);
                } else {
                    printf("\033[1;31m-\033[0m");
                }
            } else {
                printf("\033[1;35m%c\033[0m", ip[i]);
            }
            fflush(stdout);
            usleep(5000);
        }
        fflush(stdout);
        usleep(125000 + (rand() % 125001));
        printf("\r\033[K");
    } else if (glitch) {
        for (int i = 0; i < 15 && ip[i] != '\0'; i++) {
            if (rand() % 3 == 0) {
                int effect = rand() % 3;
                if (effect == 0) {
                    char emojis[] = "⚡💻🛡️";
                    printf("\033[1;31m%c\033[0m", emojis[rand() % 3]);
                } else if (effect == 1) {
                    printf("\033[90m%c\033[0m", ip[i]);
                } else {
                    printf("\033[1;31m~\033[0m");
                }
            } else {
                printf("\033[1;33m%c\033[0m", ip[i]);
            }
            fflush(stdout);
            usleep(5000);
        }
        fflush(stdout);
        usleep(125000 + (rand() % 125001));
        printf("\r\033[K");
    }
    printf("%s", ip);
}

void print_random_name(int glitch, int surprise_glitch) {
    char name[12];
    int length = 6 + rand() % 6;
    for (int i = 0; i < length; i++) {
        if (rand() % 3 == 0 && i > 0) {
            name[i] = rand() % 2 ? '0' + (rand() % 10) : '_';
        } else {
            name[i] = 'A' + (rand() % 26);
        }
    }
    name[length] = '\0';
    if (surprise_glitch) {
        for (int i = 0; i < length; i++) {
            if (rand() % 3 == 0) {
                int effect = rand() % 3;
                if (effect == 0) {
                    char emojis[] = "😈🔥💾";
                    printf("\033[5;31m%c\033[0m", emojis[rand() % 3]);
                } else if (effect == 1) {
                    printf("\033[90m%c\033[0m", name[i]);
                } else {
                    printf("\033[1;31m-\033[0m");
                }
            } else {
                printf("\033[1;35m%c\033[0m", name[i]);
            }
            fflush(stdout);
            usleep(5000);
        }
        fflush(stdout);
        usleep(125000 + (rand() % 125001));
        printf("\r\033[K");
    } else if (glitch) {
        for (int i = 0; i < length; i++) {
            if (rand() % 3 == 0) {
                int effect = rand() % 3;
                if (effect == 0) {
                    char emojis[] = "⚡💻🛡️";
                    printf("\033[1;31m%c\033[0m", emojis[rand() % 3]);
                } else if (effect == 1) {
                    printf("\033[90m%c\033[0m", name[i]);
                } else {
                    printf("\033[1;31m~\033[0m");
                }
            } else {
                printf("\033[1;33m%c\033[0m", name[i]);
            }
            fflush(stdout);
            usleep(5000);
        }
        fflush(stdout);
        usleep(125000 + (rand() % 125001));
        printf("\r\033[K");
    }
    printf("%s", name);
}

void print_hack_message(char *message, int glitch, int surprise_glitch) {
    if (surprise_glitch) {
        for (int i = 0; message[i] != '\0' && i < 29; i++) {
            if (rand() % 3 == 0) {
                int effect = rand() % 3;
                if (effect == 0) {
                    char emojis[] = "😈🔥💾";
                    printf("\033[5;31m%c\033[0m", emojis[rand() % 3]);
                } else if (effect == 1) {
                    printf("\033[90m%c\033[0m", message[i]);
                } else {
                    printf("\033[1;31m-\033[0m");
                }
            } else {
                printf("\033[1;35m%c\033[0m", message[i]);
            }
            fflush(stdout);
            usleep(5000);
        }
        printf("\n");
        fflush(stdout);
        usleep(125000 + (rand() % 125001));
        printf("\r\033[K");
    } else if (glitch) {
        for (int i = 0; message[i] != '\0' && i < 29; i++) {
            if (rand() % 3 == 0) {
                int effect = rand() % 3;
                if (effect == 0) {
                    char emojis[] = "⚡💻🛡️";
                    printf("\033[1;31m%c\033[0m", emojis[rand() % 3]);
                } else if (effect == 1) {
                    printf("\033[90m%c\033[0m", message[i]);
                } else {
                    printf("\033[1;31m~\033[0m");
                }
            } else {
                printf("\033[1;33m%c\033[0m", message[i]);
            }
            fflush(stdout);
            usleep(5000);
        }
        printf("\n");
        fflush(stdout);
        usleep(125000 + (rand() % 125001));
        printf("\r\033[K");
    }
    printf("\033[1;31m%s\n\033[0m", message);
}

void print_progress_bar(int percent, int glitch, int surprise_glitch) {
    char bar[60];
    snprintf(bar, sizeof(bar), "[");
    for (int i = 0; i < 50; i++) {
        bar[i + 1] = (i < percent / 2) ? '=' : ' ';
    }
    snprintf(bar + 51, sizeof(bar) - 51, "] %d%%", percent);
    if (surprise_glitch) {
        for (int i = 0; bar[i] != '\0' && i < 59; i++) {
            if (rand() % 3 == 0) {
                int effect = rand() % 3;
                if (effect == 0) {
                    char emojis[] = "😈🔥💾";
                    printf("\033[5;31m%c\033[0m", emojis[rand() % 3]);
                } else if (effect == 1) {
                    printf("\033[90m%c\033[0m", bar[i]);
                } else {
                    printf("\033[1;31m-\033[0m");
                }
            } else {
                printf("\033[1;35m%c\033[0m", bar[i]);
            }
            fflush(stdout);
            usleep(5000);
        }
        fflush(stdout);
        usleep(125000 + (rand() % 125001));
        printf("\r\033[K");
    } else if (glitch) {
        for (int i = 0; bar[i] != '\0' && i < 59; i++) {
            if (rand() % 3 == 0) {
                int effect = rand() % 3;
                if (effect == 0) {
                    char emojis[] = "⚡💻🛡️";
                    printf("\033[1;31m%c\033[0m", emojis[rand() % 3]);
                } else if (effect == 1) {
                    printf("\033[90m%c\033[0m", bar[i]);
                } else {
                    printf("\033[1;31m~\033[0m");
                }
            } else {
                printf("\033[1;33m%c\033[0m", bar[i]);
            }
            fflush(stdout);
            usleep(5000);
        }
        fflush(stdout);
        usleep(125000 + (rand() % 125001));
        printf("\r\033[K");
    }
    printf("\033[1;32m%s\033[0m", bar);
}

void print_gibberish_event() {
    printf("\033[?25l");
    fflush(stdout);
    clear_screen();
    time_t event_start = time(NULL);
    int count = 0;
    int positions[50][2] = {0};
    char words[50][12] = {0};
    int occupied[20][60] = {0};
    while (count < 50 && difftime(time(NULL), event_start) < 15) {
        int length = 6 + rand() % 6;
        if (length > 11) length = 11;
        for (int repeat = 0; repeat < length; repeat++) {
            if (rand() % 3 == 0 && repeat > 0) {
                words[count][repeat] = rand() % 2 ? '0' + (rand() % 10) : '_';
            } else {
                words[count][repeat] = 'A' + (rand() % 26);
            }
        }
        words[count][length] = '\0';
        int line, col;
        int attempts = 0;
        int placed = 0;
        do {
            line = rand() % 20;
            col = rand() % (60 - length);
            if (rand() % 100 < 20 && count > 0) {
                int prev = rand() % count;
                line = positions[prev][0] + (rand() % 3 - 1);
                col = positions[prev][1] + (rand() % 20 - 10);
                if (line < 0) line = 0;
                if (line >= 20) line = 19;
                if (col < 0) col = 0;
                if (col >= 60 - length) col = 60 - length - 1;
            }
            int overlap = 0;
            for (int repeat = 0; repeat < length && col + repeat < 60; repeat++) {
                if (occupied[line][col + repeat]) {
                    overlap = 1;
                    break;
                }
            }
            if (!overlap) {
                placed = 1;
                for (int repeat = 0; repeat < length && col + repeat < 60; repeat++) {
                    occupied[line][col + repeat] = 1;
                }
            }
            attempts++;
        } while (!placed && attempts < 500);
        if (!placed) {
            break;
        }
        positions[count][0] = line;
        positions[count][1] = col;
        printf("\033[%d;%dH", line + 1, col + 1);
        for (int repeat = 0; repeat < length && words[count][repeat] != '\0'; repeat++) {
            printf("\033[1;37m%c\033[0m", words[count][repeat]);
            fflush(stdout);
            usleep(1000);
        }
        float red_prob = 0.9 + (count / 50.0) * 0.1;
        if (count > 0 && difftime(time(NULL), event_start) < 14) {
            int flicker_attempts = 3;
            int flicker_duration = (count % 2 == 1) ? 60000 : 120000;
            for (int repeat = 0; repeat < flicker_attempts; repeat++) {
                if ((float)rand() / RAND_MAX < red_prob && difftime(time(NULL), event_start) < 14) {
                    int target_word = rand() % count;
                    int target_char = rand() % (strlen(words[target_word]) ? strlen(words[target_word]) : 1);
                    int target_line = positions[target_word][0];
                    int target_col = positions[target_word][1] + target_char;
                    if (target_line >= 0 && target_line < 20 && target_col >= 0 && target_col < 60) {
                        printf("\033[%d;%dH\033[1;31m%c\033[0m", target_line + 1, target_col + 1, words[target_word][target_char]);
                        fflush(stdout);
                        usleep(flicker_duration);
                        printf("\033[%d;%dH\033[1;37m%c\033[0m", target_line + 1, target_col + 1, words[target_word][target_char]);
                        fflush(stdout);
                        usleep(flicker_duration);
                        usleep(33000);
                    }
                }
            }
        }
        float delay = 13000 - (count / 50.0) * 10000;
        usleep((int)delay);
        count++;
    }
    printf("\033[H\033[?25h");
    fflush(stdout);
    clear_screen();
}

int main(int argc, char *argv[]) {
    if (argc > 1 && strcmp(argv[1], "-h") == 0) {
        printf("Available flags:\n -666 Jumps straight to the \"666\" event. (When all ips are 6.6.6.6)\n");
        exit(0);
    }

    srand(time(NULL));
    int progress = 0;
    int delay_us = 20000;
    time_t start_time = time(NULL);
    int next_glitch_time = 15 + (rand() % 16);
    int next_surprise_time = 1 + (rand() % 30);
    int surprise_in_minute = 0;
    int last_minute = 0;
    int test_mode = (argc > 1 && strcmp(argv[1], "-666") == 0);
    int event_triggered = 0;
    time_t last_event_time = 0;

    if (test_mode) {
        print_gibberish_event();
        test_mode = 0;
        last_event_time = time(NULL);
    }

    while (1) {
        clear_screen();
        int elapsed = (int)(time(NULL) - start_time);
        int glitch = elapsed >= next_glitch_time;
        int surprise = elapsed >= next_surprise_time && surprise_in_minute < 2;
        int glitch_type = rand() % 100;
        int glitch_section = rand() % 4;
        int is_6666_target = 0;
        int is_6666_warning = 0;
        event_triggered = 0;

        int ip_glitch = (glitch_type < 70 && glitch_section == 0);
        int name_glitch = (glitch_type < 70 && glitch_section == 1) || (glitch_type >= 70 && glitch_type < 90 && (glitch_section == 1 || glitch_section == 2));
        int message_glitch = (glitch_type < 70 && glitch_section == 2) || (glitch_type >= 70 && glitch_type < 90 && (glitch_section == 1 || glitch_section == 2)) || (glitch_type >= 90 && glitch_type < 97 && (glitch_section == 1 || glitch_section == 2 || glitch_section == 3));
        int bar_glitch = (glitch_type < 70 && glitch_section == 3) || (glitch_type >= 70 && glitch_type < 90 && (glitch_section == 1 || glitch_section == 2)) || (glitch_type >= 90 && glitch_type < 97 && (glitch_section == 1 || glitch_section == 2 || glitch_section == 3)) || (glitch_type >= 97);

        printf("\033[1;36m===== HACKTRON 3000 - GLOBAL DOMINATION PROTOCOL =====\033[0m\n\n");
        printf("\033[5;33mTARGET ACQUIRED: ");
        print_random_ip(glitch && ip_glitch, surprise && ip_glitch, &is_6666_target, test_mode);
        printf("\033[0m\n");
        printf("OPERATIVE: ");
        print_random_name(glitch && name_glitch, surprise && name_glitch);
        printf("\n\n");
        print_hack_message(current_hack_message, glitch && message_glitch, surprise && message_glitch);
        print_progress_bar(progress, glitch && bar_glitch, surprise && bar_glitch);
        printf("\n\033[1;35mSYSTEM STATUS: COMPROMISED\033[0m\n");
        const char *units[] = {"TERABYTES", "PETABYTES", "EXABYTES", "ZETTABYTES", "YOTTABYTES"};
        int data_breach = rand() % 1000;
        int unit_select = rand() % 100;
        int unit_index = 0;
        if (unit_select >= 80) {
            unit_index = 1 + ((unit_select - 80) / 5);
        }
        printf("DATA BREACH: \033[1;31m%d %s\033[0m\n", data_breach, units[unit_index]);
        printf("SECURITY LEVEL: \033[5;31mCRITICAL\033[0m\n");
        printf("\n\033[1;36m>>> EXECUTING EXPLOIT: ");
        print_random_name(glitch && name_glitch, surprise && name_glitch);
        printf("_V%d.%d <<<\033[0m\n", rand() % 9 + 1, rand() % 99);
        printf("\n\033[1;33mWARNING: TRACE DETECTED FROM ");
        print_random_ip(glitch && ip_glitch, surprise && ip_glitch, &is_6666_warning, test_mode);
        printf("\033[0m\n");

        if (is_6666_target && is_6666_warning && !event_triggered && (time(NULL) - last_event_time >= 30)) {
            print_gibberish_event();
            test_mode = 0;
            event_triggered = 1;
            last_event_time = time(NULL);
        }

        int steps = 100;
        int duration = 2000000 + (rand() % 10000001);
        delay_us = duration / steps;

        progress += 1;
        if (progress > 100) {
            progress = 0;
            char verbs[][15] = {"HACKING", "BREACHING", "INFILTRATING", "CRACKING", "BYPASSING", 
                               "OVERRIDING", "STEALING", "DEPLOYING", "ACCESSING", "DOWNLOADING"};
            char targets[][12] = {"MAINFRAME", "FIREWALL", "DATABASE", "ENCRYPTION", "SATELLITE", 
                                 "SECURITY", "CREDENTIALS", "PROTOCOLS", "NETWORK", "SERVERS"};
            int verb_index = rand() % 10;
            int target_index;
            if (verb_index == 9) {
                int allowed_targets[] = {0, 2, 3, 6, 7};
                target_index = allowed_targets[rand() % 5];
            } else {
                target_index = rand() % 10;
            }
            snprintf(current_hack_message, sizeof(current_hack_message), "%s %s...", verbs[verb_index], targets[target_index]);
        }

        if (elapsed >= next_glitch_time) {
            next_glitch_time = elapsed + 15 + (rand() % 16);
        }
        if (elapsed >= next_surprise_time && surprise_in_minute < 2) {
            surprise_in_minute++;
            next_surprise_time = elapsed + 1 + (rand() % 30);
        }
        int current_minute = elapsed / 60;
        if (current_minute > last_minute) {
            surprise_in_minute = 0;
            next_surprise_time = elapsed + 1 + (rand() % 30);
            last_minute = current_minute;
        }

        usleep(delay_us);
    }
    return 0;
}
