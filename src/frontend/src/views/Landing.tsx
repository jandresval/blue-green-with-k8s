import { useState, useEffect } from "react";

function Landing() {

    const [data, setData] = useState(String);
    
    useEffect(() => {
        fetch(import.meta.env.VITE_API_URL)
          .then(response => response.text())
          .then(text => setData(text))
          .catch(error => console.error(error));
      }, []);

    return (
        <div className="flex justify-center bg-gray-100 h-screen items-center">
            <div className="text-gray-800 text-center bg-gray-300 px-4 py-2 m-2">
                {data ? <pre>"{data}"</pre> : 'Loading...'}
            </div>
        </div>
    );
}

export default Landing