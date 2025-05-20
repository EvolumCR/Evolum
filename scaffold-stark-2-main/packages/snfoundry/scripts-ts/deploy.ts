import {
  deployContract,
  executeDeployCalls,
  exportDeployments,
  deployer,
} from "./deploy-contract";
import { green } from "./helpers/colorize-log";

const deployScript = async (): Promise<void> => {
  // Despliegue del contrato base YourContract
  await deployContract({
    contract: "YourContract", // Mantén esto si aún lo necesitas
    constructorArgs: {
      owner: deployer.address,
    },
  });

  // Despliegue para UserRegistry
  const userRegistryAddress = await deployContract({
    contract: "UserRegistry", // Asegúrate que este es el nombre de tu archivo Cairo (sin .cairo)
    constructorArgs: {
      // Reemplaza deployer.address con la dirección de administrador que desees
      // deployer.address es la cuenta que ejecuta el script de despliegue
      initial_admin_address: deployer.address, 
    },
  });

  // Despliegue para TokenSystem
  const tokenSystemAddress = await deployContract({
    contract: "TokenSystem",
    constructorArgs: {
      initial_admin_address: deployer.address,
    },
  });

  // Despliegue para ChallengeSystem
  await deployContract({
    contract: "ChallengeSystem", // Asegúrate que este archivo exista en contracts/src/
    constructorArgs: {
      // Ajusta estos argumentos según los requisitos del constructor de ChallengeSystem
      initial_admin_address: deployer.address,
    },
  });

  // Aquí puedes añadir más despliegues de contratos según sea necesario
};

const deployAndSetup = async (): Promise<void> => {
  try {
    await deployScript();
    await executeDeployCalls();
    exportDeployments();

    console.log(green("All Setup Done!"));
  } catch (err) {
    console.log(err);
    process.exit(1); //exit with error so that non subsequent scripts are run
  }
};

deployAndSetup();

const deployContracts = async (): Promise<void> => {
  // Despliegue del contrato base YourContract
  await deployContract({
    contract: "YourContract", // Mantén esto si aún lo necesitas
    constructorArgs: {
      owner: deployer.address,
    },
  });

  // Despliegue para UserRegistry
  const userRegistryAddress = await deployContract({
    contract: "UserRegistry", // Asegúrate que este es el nombre de tu archivo Cairo (sin .cairo)
    constructorArgs: {
      // Reemplaza deployer.address con la dirección de administrador que desees
      // deployer.address es la cuenta que ejecuta el script de despliegue
      initial_admin_address: deployer.address, 
    },
  });

  // Despliegue para TokenSystem
  const tokenSystemAddress = await deployContract({
    contract: "TokenSystem",
    constructorArgs: {
      initial_admin_address: deployer.address,
    },
  });

  // Despliegue para ChallengeSystem
  await deployContract({
    contract: "ChallengeSystem", // Asegúrate que este archivo exista en contracts/src/
    constructorArgs: {
      // Ajusta estos argumentos según los requisitos del constructor de ChallengeSystem
      initial_admin_address: deployer.address,
    },
  });

  // Aquí puedes añadir más despliegues de contratos según sea necesario
};

const main = async (): Promise<void> => {
  try {
    await deployScript();
    await executeDeployCalls();
    exportDeployments();

    console.log(green("All Setup Done!"));
  } catch (err) {
    console.log(err);
    process.exit(1); //exit with error so that non subsequent scripts are run
  }
};

main();
