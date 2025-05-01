export const LeftColumn = ({ children }: LeftColumnProps): JSX.Element => {
    return (
        <box className={`card-button-section-container`}>
                <box vertical hexpand vexpand>
                    {children}
                </box>
        </box>
    );
};

export const RightColumn = ({ children }: RightColumnProps): JSX.Element => {
    return (
        <box className={`card-button-section-container`}>
            <box vertical hexpand vexpand>
                {children}
            </box>
        </box>
    );
};

interface LeftColumnProps {
    children?: JSX.Element | JSX.Element[];
}

interface RightColumnProps {
    children?: JSX.Element | JSX.Element[];
}
