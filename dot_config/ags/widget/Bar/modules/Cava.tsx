import { App, Widget } from "astal/gtk3";
import { bind, Variable } from "astal";
import cairo from "cairo";
import Cava from "gi://AstalCava";
import { activePlayer } from "./Media";
const cava = Cava.get_default()!;

export default function Visualizer() {

    const values = bind(cava, "values");

    const setup = (self: Widget.DrawingArea) => {
        // Keep track of the signal connection ID to disconnect later
        let signalId: number;

        self.connect("draw", (_, cr: cairo.Context) => {
            
            cr.setSourceRGB(198/255, 160/255, 246/255);
            const width = self.get_allocated_width()/cava.bars;
            const height = self.get_allocated_height()-15;
            let currentX = 0;
            let currentValues = values.get();
            if (cava.get_stereo()) {
                const right = currentValues.splice(0, cava.bars/2);
                currentValues.reverse();
                currentValues = currentValues.concat(right);
            }
            currentValues.forEach((value) => {
                cr.rectangle(currentX, 32, width, value*-1*height);
                cr.fill();
                currentX += width;
            })
            cr.stroke();

        });

        // Connect to the destroy signal to clean up
        self.connect("destroy", () => {
            if (signalId) {
                cava.disconnect(signalId);
            }
        });

        // Store the signal connection ID when connecting
        signalId = cava.connect("notify::values", () => {
            // Check if the widget is still valid before queueing draw
            if (self && !self.get_parent()) {
                // Widget is not in widget tree anymore, disconnect
                cava.disconnect(signalId);
                return;
            }
            
            try {
                self.queue_draw();
            } catch (e) {
                // Widget might be in the process of being destroyed
                cava.disconnect(signalId);
            }
        });
        
        cava.set_stereo(true);
    }

    return (
        <box className={"cava"} expand={true} visible={bind(activePlayer)}>
            <drawingarea expand={true} setup={setup}/>
        </box>
    )
}