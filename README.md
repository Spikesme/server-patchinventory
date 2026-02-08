Was tut das Skript?

Erstellt ein Powershell Skript und eine html Datei. 

Das Powershell Skript wird verwendet, um es via GPO auszurollen. Das Skript erstellt eine JSON Datei mit allen installierten Updates,
inklusive Datum und KB-Nummer und speichert die JSON an "einen beliebigen" Ort. (Pfad kann angegeben werden)
Der Speichort muss eine Freigabe haben für "System" (als Computerkonto), damit die Server in den Ordner schreiben können.

Die Html Datei kann die JSON Dateien auslesen und aufrufen. Damit bekommt man ein Inventory über alle Server mit installierten Updates. 
Filter erleichtern die Suche, ob Updates installiert wurden und den Status des jeweiligen Servers, so wie der letzte Neustart.


Todos:

- Ordner erstellen und freigeben. Berechtigungen für die User setzen, die auf die Auswertung zugreifen dürfen. \System oder Domain Computer (oder ähnliches) ebenfalls mit Schreibberechtigung hinterlegen. So, dass die Server die Dateien in den freigegeben Ordner schreiben dürfen
- Freigabepfad notieren
- das "New-PatchInventoryPackage.ps1" Skript starten und die gewünschten Daten hinterlegen (lokaler Speicherordner, Freigabeordner, etc)
- Dateien werde/wurden erstellt!
- WMI Filter erstellen (empfohlen)
- GPO erstellen

GPO als Computerkonfiguration setzen. 
Einen scheduled Task anlegen.

In der GPO wird via scheduled Task das Skript aus dem netlogon aufgerufen.

Parameter sind anzupassen! (Uhrzeit und Ort des Skriptes)

Triggers
1. Daily				
Activate	29.12.2025 03:00:37	Synchronize across time zones	No
Enabled	Yes		
Recur every 1 days	


1. Start a program				
Program/script	powershell.exe		
Arguments	-NoProfile -ExecutionPolicy Bypass -File "\\domain.local\SYSVOL\domain.local\scripts\PatchInventory\Collect-PatchInventory.ps1"		
Start in	\\domain.local\SYSVOL\domain.local\scripts\PatchInventory


- die html Datei dient als GUI für die Auswertung. Beim ersten Starten der html den Pfad des freigegebenen Ordners hinterlegen. 

  


What does the script do? Creates a Powershell script and an html file. 
The Powershell script is used to roll it out via GPO. The script creates a JSON file with all installed updates, including date and KB number and 
saves the JSON to "any" location. (Path can be specified) The storage location must have a share for "System" (as a computer account) so that the servers can write to the folder. 
The html file can read and call the JSON files. This gives you an inventory of all servers with installed updates. Filters make it easier to find whether updates 
have been installed and the status of the respective server, such as the last reboot.


Todos: - Create and share folders. Set permissions for the users who are allowed to access the evaluation. 
\System or Domain Computer (or similar) also with write permission. So that the servers are allowed to write the files to the shared folder - Write down the release path - Start the "New-PatchInventoryPackage.ps1" script and 
store the desired data (local storage folder, shared folder, etc.) - Files are/have been created! - Create WMI filters (recommended) - 
Create GPO Set GPO as the computer configuration. Create a scheduled task. In the GPO, the script is called from the netlogon via scheduled task. 

Parameters have to be adjusted! 
Triggers
1. Daily				
Activate	29.12.2025 03:00:37	Synchronize across time zones	No
Enabled	Yes		
Recur every 1 days	


1. Start a program				
Program/script	powershell.exe		
Arguments	-NoProfile -ExecutionPolicy Bypass -File "\\domain.local\SYSVOL\domain.local\scripts\PatchInventory\Collect-PatchInventory.ps1"		
Start in	\\domain.local\SYSVOL\domain.local\scripts\PatchInventory

When starting the html for the first time, store the path of the shared folder.
