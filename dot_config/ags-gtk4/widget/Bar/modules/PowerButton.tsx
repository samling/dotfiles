import { execAsync } from "astal";


export default function PowerButton() {

    const handleClick = () => {
        execAsync(["wlogout"])
            .catch(error => {
                console.log(`Failed to execute wlogout: ${error.message}`);
            });
    }

    return (
        <button cssClasses={["powerButton", "barIcon"]}
        onClick={handleClick}
        >
            <image iconName="system-shutdown-symbolic"/>
        </button>
    )
}