import React, { useState, useEffect } from "react";
import logo from "./logo.svg";
import "./App.css";
import { Button, Container, AppBar, Typography, Grow, Grid } from "@material-ui/core";
import { ethers } from "ethers";
import Greeter from "./artifacts/contracts/Greeter.sol/Greeter.json";
import Contract from "./contract"

function App() {

  const [logs, setLogs] = useState([]);
  const [propertyID, setPropertyID] = useState(0);
  const [applicationID, setApplicationID] = useState(0);

  useEffect(() => {
    test();
  },[]);

  function displayMessage(msg) {    
    setLogs((logs) => [...logs, msg]);
  }

  async function test()
  {    
    var contract = new Contract();
    displayMessage("Contract instantiated.");
    await contract.initialize();
    displayMessage("Contract initialized.");    
    var propertyID = await contract.listProperty("123 main st", 1500, 2);
    displayMessage("property listed.");
    setPropertyID(propertyID);
    debugger;
    await contract.approvePropertyListing(propertyID);
    displayMessage("Approved property listing.");
    debugger;
    var applicationID = await contract.applyToRental(propertyID, 1500);
    displayMessage("Applicant apply to property : " + propertyID + " with applicationid " + applicationID);
    setApplicationID(applicationID);
    await contract.declineApplicant(applicationID);
    displayMessage("Owner declined applicant with applicationID " + applicationID);
    await contract.startRentalProcess(applicationID, applicationApproved, applicationRejected);  
    displayMessage("Property owner started the rental process...wait for the result below from oracles");
    displayMessage("waiting.......its coming....wait......");
  }

  async function applicationApproved(applicationID)
  {
    displayMessage("application : " + applicationID + " has been approved.")
  }

  async function applicationRejected(applicationID)
  {
    displayMessage("application : " + applicationID + " has been rejected.")
  }

  var property1 = require("./images/property_1.jpg").default;
  var property2 = require("./images/property_2.jpg").default;
  var property3 = require("./images/property_3.jpg").default;

  return (
    <div className="App">      
      <main>
        <Grid container>
          <Grid item xs={12}>
            <div align="left">Customer Facing Site</div>

            <Grid container>
              <Grid item xs>
                <img
                  src={property1}
                  style={{ maxWidth: "300px", maxHeight: "500px" }}
                />
                <p align="center">
                  is simply dummy text of the printing and typesetting industry.
                  Lorem Ipsum has been the industry's standard dummy text ever
                  since the 1500s, when an unknown printer took a galley of type
                  and scrambled it to make a type specimen book. It has survived               
                </p>
                <Button color="primary" variant="contained">Apply</Button>
              </Grid>
              <Grid item xs>
                <img src={property2} style={{ maxWidth: "300px", maxHeight: "500px" }}/>
                <p align="center">
                  is simply dummy text of the printing and typesetting industry.
                  Lorem Ipsum has been the industry's standard dummy text ever
                  since the 1500s, when an unknown printer took a galley of type
                  and scrambled it to make a type specimen book. It has survived               
                </p>
                <Button color="primary" variant="contained">Apply</Button>
              </Grid>
              <Grid item xs>
                <img src={property3} style={{ maxWidth: "300px", maxHeight: "500px" }}/>
                <p align="center">
                  is simply dummy text of the printing and typesetting industry.
                  Lorem Ipsum has been the industry's standard dummy text ever
                  since the 1500s, when an unknown printer took a galley of type
                  and scrambled it to make a type specimen book. It has survived               
                </p>
                <Button color="primary" variant="contained">Apply</Button>
              </Grid>
            </Grid>
          </Grid>          
          <Grid item xs={12} style={{marginTop: "100px"}}>            
        <h2> INTERNAL PROCESS BEHIND THE SCENE</h2>
          {logs.map((log) => (
          <div>{log}</div>
          ))}
          </Grid>
        </Grid>       
      </main>
    </div>
  )
}

export default App;
