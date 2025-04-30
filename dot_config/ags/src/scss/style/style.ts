import { writeFile } from "astal";
import { readFile } from "astal/file";
import { App } from "astal/gtk3";
import { bash } from "../../lib/utils";
import { initializeHotReload } from "./utils/hotReload";

export const resetCss = async (): Promise<void> => {
    try {
        const css = `${TMP}/main.css`;
        const scss = `${TMP}/entry.scss`;
        const localScss = `${SRC_DIR}/src/scss/main.scss`;

        writeFile(scss, readFile(localScss));
        await bash(`sass --load-path=${SRC_DIR}/src/scss ${scss} ${css}`);
        App.apply_css(css, true);
    } catch (error) {
        console.error(error);
    }
};

// First reset CSS, then setup hot reloading
await resetCss();
await initializeHotReload();
