# RPM File Finder

## Description
The `find_rpm.sh` script is a Bash utility designed to recursively search a given repository URL for a specified RPM file. It traverses all valid subdirectories in the repository, excluding external mirror links and non-directory paths, and prints the full URLs of any matching RPM files found. The script provides real-time feedback by displaying the current directory being searched in a single, updating line to avoid terminal clutter.

## Usage
1. **Save the Script**:
   Save the script as `find_rpm.sh`.

2. **Make it Executable**:
   ```bash
   chmod +x find_rpm.sh
   ```

3. **Run the Script**:
   Execute the script with two arguments: the repository URL and the RPM file name.
   ```bash
   ./find_rpm.sh <repo_url> <rpm_file>
   ```
   Example:
   ```bash
   ./find_rpm.sh https://vault.centos.org/ agg-2.5-18.el7.i686.rpm
   ```

## Example Output
When searching for `agg-2.5-18.el7.i686.rpm` in `https://vault.centos.org/`:
```
Searching for agg-2.5-18.el7.i686.rpm in https://vault.centos.org/...
Searching in: https://vault.centos.org/7.9.2009/os/x86_64/Packages/
Found: https://vault.centos.org/7.9.2009/os/x86_64/Packages/agg-2.5-18.el7.i686.rpm
```
If no files are found:
```
Searching for example.rpm in https://vault.centos.org/...
No instances of example.rpm found in https://vault.centos.org/
```

## Requirements
- **Bash**: The script requires a Bash shell environment.
- **curl**: Used to fetch directory listings and check file existence.
- **grep**, **sed**: Standard Unix tools for parsing HTML listings.
- A working internet connection to access the repository URL.

## Notes
- **Functionality**: The script recursively traverses all subdirectories under the provided URL, filtering out invalid links (e.g., `https://`, `rsync://`, external mirrors like `archive.kernel.org/`). It normalizes URLs to prevent issues with multiple slashes and uses URL encoding for special characters in file names.
- **Performance**: A 5-second timeout is applied to `curl` requests to avoid hanging on unresponsive directories. For large repositories, the script may take time due to multiple HTTP requests. You can add a depth limit (e.g., `if [ "$depth" -gt 10 ]; then return; fi` in the `search_rpm` function) to improve performance.
- **Debugging**: If the file isn’t found, verify the repository URL and file name. Test file accessibility directly with:
  ```bash
  curl --head https://vault.centos.org/7.9.2009/os/x86_64/Packages/agg-2.5-18.el7.i686.rpm
  ```
  Errors like 403 or 404 indicate the file or directory may be inaccessible.
- **Generality**: The script works with any repository URL hosting RPM files (e.g., `https://vault.centos.org/`, `https://repo.cloudlinux.com/cloudlinux/`) and any RPM file name.
- **Limitations**: The script relies on the repository providing HTML directory listings. If the repository uses a different format or restricts access, the script may not function as expected.
