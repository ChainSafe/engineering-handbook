# [WIP] React Project Setup

1. `npx create-react-app APP_NAME —template=typescript`
2. In the APP_NAME folder, create a `.npmrc` file with the following contents:

```jsx
registry=https://registry.yarnpkg.com/
@imploy:registry=https://npm.pkg.github.com
npm.pkg.github.com/:_authToken=${GITHUB_PACKAGES_AUTH_TOKEN}
always-auth=true
```

3. You will need a Github Personal Access token with `read:package` permissions to the Imploy package repo. This can be obtained [here](https://github.com/settings/tokens)

- Run `nano ~/.bash_profile`
- Add the following line to the file `export GITHUB_PACKAGES_AUTH_TOKEN="YOUR_TOKEN_HERE"``

4. Run `yarn add @imploy/common-components @imploy/common-themes @material-ui/styles` to install necessary dependencies

5. Replace `app.tsx` with the following

```jsx
import React from "react";
import { ThemeProvider, createTheme } from "@imploy/common-themes";

const theme = createTheme();

function App() {
  return (
    <ThemeProvider theme={theme}>
      <div className="App"></div>
    </ThemeProvider>
  );
}

export default App;
```