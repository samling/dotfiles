import { bind } from "astal"
import Wireplumber from "gi://AstalWp"
import Brightness from "./Brightness"

const brightness = Brightness.get_default()
const audio = Wireplumber.get_default()!.audio

export enum SliderType {
  AUDIO,
  BRIGHTNESS,
}

export const Slider = ({ type }: { type: SliderType }) =>
  <box
    cssClasses={["slider"]}
    spacing={4}>
    <image iconName={type === SliderType.AUDIO ?
      bind(audio.defaultSpeaker, "volume_icon") :
      "display-brightness-symbolic"} />
    <slider
      hexpand
      min={0}
      max={100}
      setup={self => type === SliderType.AUDIO ?
        self.set_value(audio.defaultSpeaker.volume) :
        self.set_value(brightness.screen * 100)}
      onChangeValue={({ value }) =>
        type === SliderType.AUDIO ?
          audio.defaultSpeaker.set_volume(value / 100) :
          brightness.set({ screen: value / 100 })
      }
      value={type === SliderType.AUDIO ?
        bind(audio.defaultSpeaker, "volume").as(v => v * 100) :
        bind(brightness, "screen").as(v => v * 100)} />
    <label
      cssClasses={["heading"]}
      label={type === SliderType.AUDIO ?
        bind(audio.defaultSpeaker, "volume").as(v =>
          Math.floor(v * 100)
            .toString()
            .concat("%")) :
        bind(brightness, "screen").as(v =>
          Math.floor(v * 100)
            .toString()
            .concat("%"))} />
  </box>
