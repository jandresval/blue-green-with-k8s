declare global {
    interface Window {
        RUNTIME_CONFIG: {
            API_URL_GREETING_ENDPOINT: string;
            // Add other configuration variables as needed
        };
    }
}

const config = {
    API_URL_GREETING_ENDPOINT: window.RUNTIME_CONFIG?.API_URL_GREETING_ENDPOINT || import.meta.env.VITE_API_URL_GREETING_ENDPOINT,
    // Add other configuration variables here
};

console.log('Window RUNTIME_CONFIG:', window.RUNTIME_CONFIG);
console.log('import.meta.env:', import.meta.env);
console.log('Final config:', config);

export default config;