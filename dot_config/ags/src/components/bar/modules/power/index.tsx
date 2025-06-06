import { Module } from '../../shared/Module';
import { inputHandler } from 'src/components/bar/utils/helpers';
import { BarBoxChild } from 'src/lib/types/bar';
import { bind, Variable } from 'astal';
import { Astal } from 'astal/gtk3';

const icon = Variable<string>('power');
const leftClick = Variable<string>('menu:powerdropdown');
const rightClick = Variable<string>('');
const middleClick = Variable<string>('');
const scrollUp = Variable<string>('');
const scrollDown = Variable<string>('');

export const Power = (): BarBoxChild => {
    const powerModule = Module({
        tooltipText: 'Power Menu',
        textIcon: bind(icon),
        showLabelBinding: Variable(false),
        boxClass: 'powermodule',
        props: {
            onDestroy: () => {
                icon.drop();
                leftClick.drop();
                rightClick.drop();
                middleClick.drop();
                scrollUp.drop();
                scrollDown.drop();
            },
            setup: (self: Astal.Button) => {
                inputHandler(self, {
                    onPrimaryClick: {
                        cmd: leftClick,
                    },
                    onSecondaryClick: {
                        cmd: rightClick,
                    },
                    onMiddleClick: {
                        cmd: middleClick,
                    },
                    onScrollUp: {
                        cmd: scrollUp,
                    },
                    onScrollDown: {
                        cmd: scrollDown,
                    },
                });
            },
        },
    });

    return powerModule;
};
