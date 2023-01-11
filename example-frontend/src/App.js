import logo from "./logo.svg";
import "./App.css";
import process from "process";

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          message: {process.env.REACT_APP_MESSAGE}
        </a>
      </header>
    </div>
  );
}

export default App;
