![Mangafox downloader logo (a page of manga).](https://raw.githubusercontent.com/HermesPasser/MangaFox-Downloader/master/app-icon.png)
Download mangas from the brazilian's site Manga Host.

**NOTE: This program will not be updated anymore.**

## Usage  

Needs ruby 2.4 or higher to work.  

Note: some methods useds can be depreciated or removed in newer versions, i recommend the usage of 2.* versions.

### Command line arguments  

#### Help & other functionalities  

``h:`` to show help.  
``u:`` to update the program.    
``d:`` to change the default folder (default is program_folder/mangas/). The value is stored in a file so you only need to change once.  

#### Downloading

See the image below to undertand where get the information of the chapter that you want to download:  
![how to know the name and chapter from a manga host url](https://raw.githubusercontent.com/HermesPasser/Manga-Host-Downloader/master/about.png)
If there is a volume it will be before the chapter. The number after the chapter is the current page and should be ignored.   

``m:<manga_name>`` replace \<manga_name\> with the name of the manga. 
``c:<chapter_name>`` replace \<chapter_name\> with the name of chapter.  
``v:<volume_name>`` replace \<volume_name\> with the name of volume. Ignore this parameter if the manga does not have one. (optional)  
``p:<path>`` replace \<path\> with the path you want to download. This will just download the current manga in the selected folder and will not replace the default folder. (optional)  
``l:<domain>`` to set the url that manga host site is in (just in case, sometimes they change the domain).   

e.g: ``m:manga_name c:01 p:c:\folder`` or ``m:other_manga c:5.5 v:4`` or ``m:manga_name c:1 l:mangahost.net``  

Watch a video with the whole process [here](https://www.youtube.com/watch?v=mDmbRwZjkas).
