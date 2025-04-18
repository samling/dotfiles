import { execAsync } from "astal";


export default function PowerButton() {

    const handleClick = () => {
        execAsync(["adios", "--systemd"]);
    }

    return (
        <button className="powerButton barIcon"
        onClick={handleClick}
        >
            <icon icon="system-shutdown-symbolic"/>
        </button>
    )
}