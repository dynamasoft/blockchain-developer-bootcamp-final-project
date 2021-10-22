import React, { useState, useEffect } from "react";
import logo from "./logo.svg";
import "./App.css";
import {
  Button,
  Container,
  AppBar,
  Typography,
  Grow,
  Grid,
} from "@material-ui/core";
import { ethers } from "ethers";
import Greeter from "./artifacts/contracts/Greeter.sol/Greeter.json";
import Contract from "./contract";

function App() {
  const [logs, setLogs] = useState([]);
  const [propertyID, setPropertyID] = useState(0);
  const [applicationID, setApplicationID] = useState(0);
  const [contract, setContract] = useState();

  useEffect(() => {
    setContract(new Contract());
    displayMessage("Contract instantiated.");
  }, []);

  function displayMessage(msg) {
    setLogs((logs) => [...logs, msg]);
  }

  const start = async () => {
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
    displayMessage(
      "Applicant apply to property : " +
        propertyID +
        " with applicationid " +
        applicationID
    );
    setApplicationID(applicationID);
    await contract.declineApplicant(applicationID);
    displayMessage(
      "Owner declined applicant with applicationID " + applicationID
    );
    await contract.startRentalProcess(
      applicationID,
      applicationApproved,
      applicationRejected
    );
    displayMessage(
      "Property owner started the rental process...wait for the result below from oracles"
    );
    displayMessage("waiting.......its coming....wait......");
  };

  async function applicationApproved(applicationID) {
    displayMessage("application : " + applicationID + " has been approved.");
  }

  async function applicationRejected(applicationID) {
    displayMessage("application : " + applicationID + " has been rejected.");
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
                  I have a Master Bedroom for rent in a townhome, you will have
                  your own bedroom and bathroom with walk in closet, garden tub,
                  and shower. The kitchen, living room, and washer/dryer is
                  shared. Close to Brandon Mall, I-, and many restaurants. This
                  is a safe family gated community with a pool.
                </p>
                <Button color="primary" variant="contained" onClick={() => start()}> 
                  Apply
                </Button>
              </Grid>
              <Grid item xs>
                <img
                  src={property2}
                  style={{ maxWidth: "300px", maxHeight: "500px" }}
                />
                <p align="center">
                  Looking for a new roommate. A stunning NEWLY RENOVATED
                  Victorian terrace with an abundance of CHARACTER FEATURES,
                  located within the catchment area of EXCELLENT SCHOOLS and
                  benefiting from a wealth of local amenities. It would make the
                  perfect FAMIILY HOME.
                </p>
                <Button color="primary" variant="contained" onClick={() => start()}>
                  Apply
                </Button>
              </Grid>
              <Grid item xs>
                <img
                  src={property3}
                  style={{ maxWidth: "300px", maxHeight: "500px" }}
                />
                <p align="center">
                  Room for Rent in Beautiful & Safe West San Jose'. Room is
                  fully furnished~for one person, only. Looking for one person
                  who is very quiet, clean, neat, responsible & respectful. Home
                  is Chemical & Scent free & Environmentally healthy &
                  conscious. Rent is: $, per month with security deposit of
                  same. $, non refundable cleaning fee is required. Must have
                  work/personal & previous rental references. Close to tech,
                  hospitals, shopping & freeways. Walk to Santana Row &
                  Winchester Mystery House. Park in driveway.
                </p>
                <Button
                  color="primary"
                  variant="contained"
                  onClick={() => start()}
                >
                  Apply
                </Button>
              </Grid>
            </Grid>
          </Grid>
          <Grid item xs={12} style={{ marginTop: "100px" }}>
            <h2> INTERNAL PROCESS BEHIND THE SCENE</h2>
            {logs.map((log) => (
              <div>{log}</div>
            ))}
          </Grid>
        </Grid>
      </main>
    </div>
  );
}

export default App;
