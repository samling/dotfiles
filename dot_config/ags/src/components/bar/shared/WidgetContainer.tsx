import { BarBoxChild } from 'src/lib/types/bar';
import { Bind } from 'src/lib/types/variable';
import { bind } from 'astal';

const computeVisible = (child: BarBoxChild): Bind | boolean => {
    if (child.isVis !== undefined) {
        return bind(child.isVis);
    }
    return child.isVisible;
};

export const WidgetContainer = (child: BarBoxChild): JSX.Element => {
    const buttonClassName = (() => {
        const boxClassName = Object.hasOwnProperty.call(child, 'boxClass') ? child.boxClass : '';

        return `bar_item_box_visible default ${boxClassName}`;
    })();

    if (child.isBox) {
        return (
            <eventbox visible={computeVisible(child)} {...child.props}>
                <box className={buttonClassName}>{child.component}</box>
            </eventbox>
        );
    }

    return (
        <button className={buttonClassName} visible={computeVisible(child)} {...child.props}>
            {child.component}
        </button>
    );
};
