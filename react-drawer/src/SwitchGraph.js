import { useState, useEffect } from "react";
import React from "react";
import { Graph } from "react-d3-graph";
import default_config, { minZoom } from "./default_config";
import "./graph.css";
import Fab from '@mui/material/Fab';
import RefreshIcon from '@mui/icons-material/Refresh';
import default_data from "./default_data";

const BACKEND_URL = 'http://127.0.0.1:5920/json';
const SwitchGraph = () => {
  const [config, setConfig] = useState(default_config);
  const [data, setData] = useState(default_data);


  const handleSize = () => {
    setConfig({
        ...config,
      height: window.innerHeight,
      width: window.innerWidth,
    });
    console.log(config.height, config.width);
  };
  useEffect(() => {
    window.addEventListener("resize", handleSize);
    return () => window.removeEventListener("resize", handleSize)
  });

  const handleClick = () => {
    fetch(BACKEND_URL).then(
      (response) => {
        if (response.status !== 200) {
          console.log(`Looks like there was a problem. Status Code: ${response.status}`);
          return;
        }
        response.json().then((_data) => {
          setData(_data);
          console.log(_data);
          console.log(data);
        });
      }
    )
  }


  return (
    <div>
      <div className="title-bar">

      <Fab color="primary" aria-label="refresh" onClick={handleClick}>
        <RefreshIcon />
      </Fab>
      </div>
      <Graph id="graph" config={config} data={data} />
    </div>
  );
};

export default SwitchGraph;
