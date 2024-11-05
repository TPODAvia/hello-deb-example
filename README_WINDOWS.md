A script to create an executable (.exe) file for Windows that packages your Docker Compose application. We'll use **Inno Setup**, a free installer creation tool for Windows, to build an installer that will:

- Copy your application files (`docker-compose.yml`, `Dockerfile`, `hello.py`) to a specified directory on the user's machine.
- Check if Docker Desktop is installed and prompt the user to install it if not.
- Run `docker-compose up` after installation to build and start the Docker container.

---

### **Steps to Create the Windows Installer**

#### **1. Prepare Your Application Files**

Ensure your directory structure looks like this:

```
test/
├── src/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── hello.py
│   └── RunDockerCompose.bat
└── create_installer.iss
```

- **`hello.py`**

  ```python
  #!/usr/bin/env python3
  print("Hello, world!")
  ```

- **`Dockerfile`**

  ```dockerfile
  # Use the official Python image from Docker Hub
  FROM python:3.9-slim

  # Set the working directory
  WORKDIR /app

  # Copy the Python script into the container
  COPY hello.py .

  # Run the Python script
  CMD ["python", "hello.py"]
  ```

- **`docker-compose.yml`**

  ```yaml
  version: '3'

  services:
    hello-world-app:
      build: .
      container_name: hello_world_container
  ```

- **`RunDockerCompose.bat`**

  ```batch
  @echo off
  docker-compose up -d --build
  pause
  ```

#### **2. Install Inno Setup**

Download and install Inno Setup from [https://jrsoftware.org/isinfo.php](https://jrsoftware.org/isinfo.php).

#### **3. Create the Inno Setup Script**

Create a file named `create_installer.iss` in the `test` directory with the following content:

```ini
; create_installer.iss
[Setup]
AppName=Hello World Docker
AppVersion=1.0.0
DefaultDirName={pf}\HelloWorldDocker
DefaultGroupName=Hello World Docker
UninstallDisplayIcon={app}\hello_world.ico
Compression=lzma
SolidCompression=yes
OutputBaseFilename=HelloWorldDockerInstaller
PrivilegesRequired=admin

[Files]
Source: "src\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Run Hello World Docker"; Filename: "{app}\RunDockerCompose.bat"; WorkingDir: "{app}"

[Run]
Filename: "{app}\RunDockerCompose.bat"; WorkingDir: "{app}"; Flags: shellexec postinstall skipifsilent

[Code]
function IsDockerInstalled(): Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('cmd.exe', '/C docker --version', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure InitializeWizard();
begin
  if not IsDockerInstalled() then
  begin
    MsgBox('Docker Desktop is not installed. Please install Docker Desktop before proceeding.', mbInformation, MB_OK);
    ShellExec('open', 'https://www.docker.com/products/docker-desktop', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    Abort();
  end;
end;
```

#### **4. Compile the Installer**

- Open **Inno Setup Compiler**.
- Load `create_installer.iss`.
- Click on **Compile**.

#### **5. Distribute the Installer**

After compilation, you'll have `HelloWorldDockerInstaller.exe` in the output directory. You can distribute this executable to users.

---

### **Explanation of the Script**

- **[Setup] Section**

  - `AppName`: Name of your application.
  - `AppVersion`: Version of your application.
  - `DefaultDirName`: Installation directory.
  - `PrivilegesRequired=admin`: Ensures the installer runs with administrator privileges.
  - Other settings handle compression and output file naming.

- **[Files] Section**

  - Specifies which files to include in the installer and where to place them on the user's system.

- **[Icons] Section**

  - Creates a Start Menu shortcut to `RunDockerCompose.bat`.

- **[Run] Section**

  - Executes `RunDockerCompose.bat` after installation.

- **[Code] Section**

  - **`IsDockerInstalled` Function**: Checks if Docker is installed by attempting to run `docker --version`.
  - **`InitializeWizard` Procedure**: If Docker is not installed, it prompts the user and opens the Docker Desktop download page.

---

### **Notes**

- **Docker Desktop Requirement**: The user must have Docker Desktop installed for the application to work.
- **Administrator Privileges**: The installer requires admin rights to ensure proper installation and execution.
- **Error Handling**: If Docker is not installed, the installer will guide the user to install it.
- **Batch Script (`RunDockerCompose.bat`)**: Builds and runs the Docker container.

---

### **Final Directory Structure**

Ensure your `test` directory looks like this before compiling:

```
test/
├── src/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── hello.py
│   ├── RunDockerCompose.bat
│   └── hello_world.ico (optional)
└── create_installer.iss
```

---

### **Running the Installer**

1. Execute `HelloWorldDockerInstaller.exe`.
2. Follow the installation prompts.
3. After installation, the Docker container will build and run automatically.
4. You can also use the Start Menu shortcut **Run Hello World Docker** to rerun the application.

---

### **Testing the Application**

- Open a command prompt.
- Run `docker ps` to see if `hello_world_container` is running.
- You can check the logs using `docker logs hello_world_container`.

---

### **Uninstallation**

- Use **Add or Remove Programs** in Windows to uninstall **Hello World Docker**.
- The uninstaller will remove the application files but won't remove Docker images or containers.

---

### **Customization**

- **Application Icon**: Include a `hello_world.ico` in the `src` directory and adjust the `UninstallDisplayIcon` path if you want a custom icon.
- **Version Updates**: Update the `AppVersion` in the `.iss` script for new releases.
- **Additional Files**: Add any other necessary files to the `src` directory, and they will be included in the installer.

---

Feel free to ask if you need further assistance or customization!