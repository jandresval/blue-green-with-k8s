import { useState, useEffect } from "react";
import config from '../config';

function Landing() {
    const [data, setData] = useState(String);

    useEffect(() => {
        fetch(config.API_URL + '/greeting')
            .then((response) => response.text())
            .then((text) => setData(
                JSON.parse(text)
            ))
            .catch((error) => {
                console.error(error);
                setData("Error fetching data");
            });
    }, []);

    return (
        <div className="flex justify-center bg-gray-100 h-screen items-center">
            <div className="text-gray-800 text-center bg-gray-300 px-4 py-2 m-2">
                { data ? <pre>{ data }</pre> : 'Loading...' }
            </div>
        </div>
    );
}

export default Landing