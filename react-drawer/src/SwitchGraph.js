import { useState, useEffect } from "react";
import React from "react";
import { Graph } from "react-d3-graph";
import default_config, { minZoom } from "./default_config";
import "./graph.css";
import Fab from '@mui/material/Fab';
import RefreshIcon from '@mui/icons-material/Refresh';
import data from './data';



const SwitchGraph = () => {
  const [config, setConfig] = useState(default_config);

  const handleSize = (_) => {
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


  return (
    <div>
      <div className="title-bar">

      <Fab color="primary" aria-label="refresh">
        <RefreshIcon />
      </Fab>
      </div>
      <Graph id="graph" config={config} data={data} />
    </div>
  );
};

export default SwitchGraph;
