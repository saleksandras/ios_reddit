# The Reddit App Home Challenge

General guidelines:
- Feel free to use any open-source 3rd party libraries you like (it’s encouraged)
- If you take code snippets from external sources (e.g. stackoverflow), please provide a reference of the snippet source
- Target the project to the latest version of the OS, no need for backwards compatibility
- Get extra points for adding tests

We’d like to build an app for browsing your favorite reddit channel (w  ww.reddit.com)  , so first familiarize yourself with the reddit API -  https://www.reddit.com/dev/api. 

1. Let’s start by creating a new mobile app project with 2 tabs.

- Pick your favorite reddit channel (or use “/top” channel), and set it as the first tab’s name
- Add a list in that tab that will display the 25 most recent items in the channel
- Entries in the list should display the post title and thumbnail (if an image exists)
- Feel free to design the UI as you see fit
- When clicking on a post, open a new WebView to display the post’s content

2. We’d like the app to be able to browse more than the recent 25 posts. Modify the app to display earlier posts by fetching them on-demand while the user scrolls the list, and provide an infinite scroll experience (use batches of 25 posts).

- Make sure you provide a decent UX (e.g. progress indicators) if the user reaches the list bottom before new data has been fetched

3. We’d like to allow our users to save their favorite posts.

- In the post WebView screen, add a button that will enable the user to save/remove the post from his favorites list. The button should indicate if the post is currently a favorite
- Name the second tab “favorites” and display a list of all posts marked as favorites
- Clicking on a post in the favorites list should open the same post WebView screen as in the first tab channel list
- No need to persist the favorites data

4. Finally, we’d like to add filtering to the list based on the post titles. Add a search field to the top of the channel list that will allow the user to type in text that will apply the filter.

- The filter should apply only to already fetched items
- The filter should match search terms that have at least 3 letters and can be found anywhere within the a post title. For example: “cat” should match “my cute cat sleeping” and also “cool catamaran”

Good luck!

# Result

- Objectice-C
- Storyboards
- 3rd party libraries:
  * https://github.com/samvermette/SVProgressHUD
  * https://github.com/advantis/ADVUserDefaults
  
- [x] “/top” channel tab
- [x] Display the post title and thumbnail (if an image exists)
- [x] Infinite scroll experience
- [x] Filtering
- [x] Post in webview
- [x] “Favorites” tab
- [ ] Add test

## Screenshots

![top list](https://github.com/saleksandras/ios_reddit/blob/master/screenshots/top.png "Top list")
![top list](https://github.com/saleksandras/ios_reddit/blob/master/screenshots/top2.png "Top list 2")
![favorites](https://github.com/saleksandras/ios_reddit/blob/master/screenshots/favorites.png "Favorites")
![webview](https://github.com/saleksandras/ios_reddit/blob/master/screenshots/webview.png "Webview")
![search](https://github.com/saleksandras/ios_reddit/blob/master/screenshots/search.png "Search")
![loading](https://github.com/saleksandras/ios_reddit/blob/master/screenshots/loading.png "Loading")
