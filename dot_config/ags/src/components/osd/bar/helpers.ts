import { bind, Variable } from 'astal';
import AstalWp from 'gi://AstalWp?version=0.1';
import LevelBar from 'src/components/shared/LevelBar';
import Brightness from 'src/services/Brightness';

const wireplumber = AstalWp.get_default() as AstalWp.Wp;
const audioService = wireplumber.audio;

const brightnessService = Brightness.get_default();

/**
 * Sets up the OSD bar for a LevelBar instance.
 *
 * This function hooks various services and settings to the LevelBar instance to update its value and class name
 * based on the brightness and audio services. It handles screen brightness, keyboard brightness, microphone volume,
 * microphone mute status, speaker volume, and speaker mute status.
 *
 * @param self The LevelBar instance to set up.
 */
export const setupOsdBar = (self: LevelBar): void => {
    self.hook(brightnessService, 'notify::screen', () => {
        self.className = self.className.replace(/\boverflow\b/, '').trim();
        self.value = brightnessService.screen;
    });

    self.hook(brightnessService, 'notify::kbd', () => {
        self.className = self.className.replace(/\boverflow\b/, '').trim();
        self.value = brightnessService.kbd;
    });

    Variable.derive([bind(audioService.defaultMicrophone, 'volume')], () => {
        self.toggleClassName('overflow', audioService.defaultMicrophone.volume > 1);
        self.value =
            audioService.defaultMicrophone.volume <= 1
                ? audioService.defaultMicrophone.volume
                : audioService.defaultMicrophone.volume - 1;
    });

    Variable.derive([bind(audioService.defaultMicrophone, 'mute')], () => {
        self.toggleClassName(
            'overflow',
            audioService.defaultMicrophone.volume > 1 &&
                (audioService.defaultMicrophone.mute === false),
        );
        self.value =
            audioService.defaultMicrophone.mute !== false
                ? 0
                : audioService.defaultMicrophone.volume <= 1
                  ? audioService.defaultMicrophone.volume
                  : audioService.defaultMicrophone.volume - 1;
    });

    Variable.derive([bind(audioService.defaultSpeaker, 'volume')], () => {
        self.toggleClassName('overflow', audioService.defaultSpeaker.volume > 1);
        self.value =
            audioService.defaultSpeaker.volume <= 1
                ? audioService.defaultSpeaker.volume
                : audioService.defaultSpeaker.volume - 1;
    });

    Variable.derive([bind(audioService.defaultSpeaker, 'mute')], () => {
        self.toggleClassName(
            'overflow',
            audioService.defaultSpeaker.volume > 1 &&
                (audioService.defaultSpeaker.mute === false),
        );
        self.value =
            audioService.defaultSpeaker.mute !== false
                ? 0
                : audioService.defaultSpeaker.volume <= 1
                  ? audioService.defaultSpeaker.volume
                  : audioService.defaultSpeaker.volume - 1;
    });
};
