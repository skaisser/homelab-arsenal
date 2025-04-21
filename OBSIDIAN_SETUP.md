# 📚 Using Linux4Noobs with Obsidian

This guide will help you set up Linux4Noobs as an Obsidian vault for offline access and easy navigation.

## 🚀 Quick Setup

1. **Install Obsidian**
   - Download from [https://obsidian.md](https://obsidian.md)
   - Install it on your system

2. **Clone the Repository**
   ```bash
   git clone https://github.com/linux4noobs/linux4noobs.git
   ```

3. **Open in Obsidian**
   - Open Obsidian
   - Click "Open folder as vault"
   - Navigate to your cloned `linux4noobs` folder
   - Select the folder and click "Open"

## ⚙️ Recommended Settings

1. **Enable Essential Plugins**
   - Go to Settings → Core Plugins
   - Enable the following:
     - Page Preview
     - Tag pane
     - File explorer
     - Search
     - Backlinks
     - Graph view

2. **Configure Graph View**
   - Open Graph View (click graph icon in left sidebar)
   - Recommended filters:
     - Show tags
     - Group by folders
     - Show file names

3. **Enable Safe Mode**
   - Keep Safe Mode on (Settings → Safe Mode)
   - This repository doesn't require any community plugins

## 📝 Using the Documentation

1. **Navigation**
   - Use the File Explorer to browse documents
   - Click on any `[[wiki-style]]` links to navigate between documents
   - Use tags (e.g., #docker, #zfs, #truenas) to find related content

2. **Search**
   - Use `Ctrl/Cmd + F` for in-file search
   - Use `Ctrl/Cmd + Shift + F` for vault-wide search

3. **Backlinks**
   - Open the backlinks pane to see which documents reference the current one
   - Helpful for discovering related content

## 🔄 Keeping Updated

1. **Pull Latest Changes**
   ```bash
   cd path/to/linux4noobs
   git pull origin main
   ```

2. **Refresh Obsidian**
   - Press `Ctrl/Cmd + R` to refresh Obsidian
   - Or click the "Reload app" button in Settings

## 📱 Mobile Access

1. **Install Obsidian Mobile**
   - Available for iOS and Android
   - Use the same vault across devices

2. **Sync Options**
   - Use Git mobile apps for manual sync
   - Or use Obsidian Sync (paid feature)
   - Or use third-party sync (iCloud, Dropbox, etc.)

## 💡 Tips

- Use the Graph View to visualize connections between documents
- Create your own notes in a separate folder to keep them distinct from the main documentation
- Use tags to organize and find related content quickly
- Star frequently accessed files for quick access

## ❓ Troubleshooting

- If links appear broken, ensure you're in the root folder of the repository
- If images don't load, check that you've pulled all files from the repository
- For any issues, check the [GitHub Issues](https://github.com/linux4noobs/linux4noobs/issues) page
