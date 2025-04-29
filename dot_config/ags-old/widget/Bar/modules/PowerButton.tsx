import { execAsync } from "astal";


export default function PowerButton() {

    const handleClick = () => {
        execAsync(["wlogout"])
            .catch(error => {
                console.log(`Failed to execute wlogout: ${error.message}`);
            });
    }

    return (
        <button className="powerButton barIcon"
        onClick={handleClick}
        >
            <icon icon="system-shutdown-symbolic"/>
        </button>
    )
}