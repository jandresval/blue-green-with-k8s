import React from 'react'
import ReactDOM from 'react-dom/client'
import './index.css'

import "@fortawesome/fontawesome-free/css/all.min.css";

import Landing from "./views/Landing.tsx";

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Landing />
  </React.StrictMode>,
);
