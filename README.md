# Smart Contracts Casino

## Author
* Dominik Moser (e0726744)
* Martin Prebio (e1025737)

## Build

The project consists of three sub projects.  
Building all projects with gradle:  
```bash
gradlew build
```

### Casino Contract

Including the casino smart contract as well as the casino token.  
Both of them are written in solidity and can be built using gradle:  
```bash
gradlew :casino-contract:build
```

### Casino Oracle

The oracle is written in kotlin and can be built using gradle:  
```bash
gradlew :casino-oracle:build
```

### Casino WebUI

Is a website where users can play in the casino.  
The oracle is written in react and can be built using gradle:  
```bash
gradlew :casino-web:build
```