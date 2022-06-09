<h1 align="center">qb-pefcl</h1>


**This is a compatibility resource that enables PEFCL to function properly with QBCore. Please ensure that you have the latest version
of PEFCL and QBCore installed**

## Installation Steps:
1. Download this repository and place it in the `resources` directory
2. Add `ensure qb-pefcl` to your `server.cfg` (Start this resource after `QBCore` and `PEFCL` have been started)
3. Navigate to the `config.json` in `PEFCL` and change the following settings under `FrameworkIntegration`:
	a. `enabled` to `true`
	b. `exportResource` to `qb-pefcl`
 
 
**Note this currently only works on PEFCL develop branch**
