import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import UserPage from './components/userpage';
import OwnerPage from './components/ownerpage';



function App() {
  return (
    <Router>
      <Routes>
      
        <Route path="/owner" element={<OwnerPage />} />
        <Route path="/user" element={<UserPage />} />
      </Routes>
    </Router>
  );
}

export default App;
