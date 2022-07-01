import React from "react";
import { 
  BrowserRouter,
  Routes,
  Route, } from "react-router-dom";
import Layout from "./components/Layout";
import Meat from "./pages/meat";
import Larvae from "./pages/larvae";
import LarvaDetails from "./pages/larvae/LarvaDetails";
import DroneDeatils from "./pages/meat/droneDetails";
import MeatDetails from "./pages/meat/meatDetails";
import Options from "./pages/more/options";
import Achievements from "./pages/more/achievements";
import Statistics from "./pages/more/statistics";
import Changelog from "./pages/more/changelog";
import Contact from "./pages/more/contact";
import All from "./pages/more/all";
import CrystalDetails from "./pages/more/all/crystal";
import 'bootstrap/dist/css/bootstrap.min.css';

function App() {
  return (
      <BrowserRouter>
        <Layout>
          <Routes>
            <Route exact path="/meat" element={ <Meat />}>
              <Route path="drone" element={<DroneDeatils />} />
              <Route path="meat" element={<MeatDetails />} />
            </Route>
            <Route path="/larvae" element={<Larvae />}>
              <Route path="larva" element={<LarvaDetails />} />
            </Route>
            <Route path="/options" element={<Options />} />
            <Route path="/achievements" element={<Achievements />} />
            <Route path="/statistics" element={<Statistics />} />
            <Route path="/changelog" element={<Changelog />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/all" element={<All />}>
              <Route path="meat" element={<MeatDetails />} />
              <Route path="larva" element={<LarvaDetails />} />
              <Route path="crystal" element={<CrystalDetails />} />
              <Route path="drone" element={<DroneDeatils />} />
            </Route>
          </Routes>
        </Layout>
      </BrowserRouter>
  );
}

export default App;
