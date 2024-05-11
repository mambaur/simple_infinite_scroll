
Simple infinite scroll listview is a package that helps you simplify the process of displaying large amounts of data, and you want to display it in unlimited pagination.

## Features

* Infinite scroll listview
* Dart generic
* Automatic pagination
* Customizable loading widget
* Refresh listview
* Customizable listview empty widget.
* Customizable listview error widget.
* Customizable listview when end of list is reached widget.

## Usage

The `SimpleInfiniteScroll` is very similar to that of `ListView.builder`. A basic implementation requires following parameters:

* `itemBuilder` : widget that represents each index item in the data list.
* `controller` : controls various behaviors in the listview.
* `initialPage` : the initial value of the page that is loaded, by default is `1`.
* `limit` : the amount of data displayed on each page.
* `loadingWidget` : widget that will be displayed when the scroll is maximum.
* `fetch` : the function used to get the data list, contains callback parameters such as `page` and `limit`, which you can use as parameters for calling data from the repository, by default is `10`.

The following is an example of a listview code snippet with model data

```dart
SimpleInfiniteScroll<Article>(
    initialPage: 1,
    limit: 10,
    fetch: (page, limit) => fetchArticles(page, limit),
    itemBuilder: (context, index, item){
        return ListTile(
            title: Text(item.title),
        );
    }
)
```

You can fetch repository data like this:

```dart
Future<List<Article>?> fetchArticles(page, limit) async{
    // fetch articles data...
}
```

## Refresh

This package is equipped with a refresh feature that makes it easy for you to reload data in the listview display.
You can refresh the listview by utilizing `SimpleInfiniteScrollController`.

```dart
final SimpleInfiniteScrollController _scrollController =
      SimpleInfiniteScrollController();
_scrollController.refresh();
```

To change the style of the refresh indicator, add the `refreshIndicatorStyle` property.

```dart
SimpleInfiniteScroll<Article>(
    refreshIndicatorStyle: RefreshIndicatorStyle(
        color: Colors.green,
        displacement: 40.0,
        backgroundColor: Colors.grey.shade200
    ),
)
```

## Let us know!

I would be happy if you send us feedback on your projects where you use our component. Just email bauroziq@gmail.com and let me know if you have any questions or suggestions about my work.