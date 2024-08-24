declare global {
    interface Window {
        RUNTIME_CONFIG: {
            API_URL: string;
        };
    }
}

const config = {
    API_URL: window.RUNTIME_CONFIG?.API_URL || import.meta.env.VITE_API_URL,
};

console.log('Window RUNTIME_CONFIG:', window.RUNTIME_CONFIG);
console.log('import.meta.env:', import.meta.env);
console.log('Final config:', config);

export default config;