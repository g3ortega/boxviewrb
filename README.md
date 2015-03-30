# boxview.rb

[![Build Status](https://travis-ci.org/getlua/boxviewrb.svg)](https://travis-ci.org/getlua/boxviewrb)

A BoxView API wrapper. Built using the power of HTTParty to communicate with the BoxView API. The BoxView API has added some new features and improved documentation, this lib takes care of all of those new additions for you. You can learn more at the [developer page](http://developers.box.com/view/). Note this product and API are still in beta, and likely to change in the future. Boxviewrb works with all available requests that are documented by BoxView at the time of writing.

##### Table of Contents
* [Installation](#installation)
* [Usage](#usage)
    * [Configuration](#configuration)
    * [Document](#document)
        * [Create](#create-document)
        * [MultiPart](#multipart)
        * [List](#list)
        * [Show](#show)
        * [Update](#update)
        * [Delete](#delete)
        * [Thumbnail](#thumbnail)
        * [Assets](#assets)
    * [Session](#session)
        * [Create](#create-session)
    * [Convenience Methods](#convenience-methods)
        * [Never Expire](#never-expire)
        * [View](#create-session)
        * [ViewerJS URL](#viewerjs-url)
        * [Viewer URL](#viewer-url)
        * [Supported MIMETypes](#supported-mimetypes)
        * [Supported File Extensions](#supported-file-extensions)
* [Contributing](#contributing)
* [Author](#author)
* [License](#license)

## Installation

Add this line to your application's Gemfile:

    gem 'boxview.rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boxview.rb

## Usage

### Configuration

Defining an api key is the only required configuration. To get your own API Key, visit [Box and get a developer account](https://app.box.com/developers/services). Then create a new Box View application. Scroll to the bottom of the application settings page to find your api key.

```ruby
BoxView.api_key = "#{BOXVIEW_APIKEY}" # Example: 'gyheecmm6ckk8jutlowlzfh2tbg72kck'
```

### Document

#### Create

See below for how to create a document using boxviewrb. Not all the paramaters used are required. The url is the only parameter that will be necessary in order to make a successful call with the BoxView API. Name refers to the name of the document. Non_SVG refers to whether you want to support browsers that cannot support svg. The Height and Width parameters refer to the size of a thumbnail that will give Box an early start to generating your thumbnail for you. You must still make a second request for a thumbnail, but it will be made available sooner upon request.

After this call is made, the BoxView API will return with a response. Boxviewrb will automatically have the document id available when the response is returned, call `BoxView.document_id` to retrieve it. If the call to BoxView fails, a specific error will be raised depending on what went wrong.

Required: `url`

Optional: `name`, `non_svg`, `width and height`

```ruby
BoxView::Document.create
  url: 'http://seriousmonkeybusiness.com/chimpanzee.docx',
  name: 'chimpanzee',
  non_svg: true,
  width: 100,
  height: 100
```

#### MultiPart

If you have access to the actual file you want to upload to box, you can directly upload it via a multipart upload. This method requires the path to the file to be specified in order for it to send the file to box. If the filepath does not exist, an error will be thrown. The other params (name, thumbnail and non_svg) are the same as the create request params.

Required: `filepath`

Optional: `name`, `non_svg`, `width and height`

```ruby
BoxView::Document.multipart
  filepath: '/Documents/sample.docx',
  name: 'sample',
  non_svg: true,
  width: 100,
  height: 100
```

#### List

This request will respond with a list of all the documents that are currently tied to the api key that has been supplied. Delete requests will remove documents from this list. This method returns the response untouched.

```ruby
BoxView::Document.list
```

#### Show

Returns the metadata for a single document based on a specified document id. If the document has successfully been generated by box, the status of the document will be 'done'. If not the status will be 'error'. The status is returned in the response when calling show.

Required: `document_id`

```ruby
BoxView::Document.show document_id: '937778a1a54b4337a5351a78f7188a24'
```

#### Update

Update the metadata of a single document based on a specified document id. Only the name can be updated at this time.

Required: `document_id`, `name`

```ruby
BoxView::Document.update
  document_id: '937778a1a54b4337a5351a78f7188a24',
  name: 'recipes'
```

#### Delete

Removes a previously created document from the Box View servers. This request is destructive.

Required: `document_id`

```ruby
BoxView::Document.delete document_id: '937778a1a54b4337a5351a78f7188a24'
```

#### Thumbnail

A request to retrieve a thumbnail representation of a document. A document id must be specified in order to make the request. If the server response contains the response code `202` then the retry after attribute will be available when calling `BoxView::Document.retry_after`. This can be useful if Box is rate limiting.

Required: `document_id`, `width and height`

```ruby
BoxView::Document.thumbnail
  document_id: '937778a1a54b4337a5351a78f7188a24',
  width: 100,
  height: 100
```

#### Assets

A request to retrieve a pdf or zip of the asset that was uploaded. The document will be retrieved as a pdf or zip. The zip contains compressed css/js/html that make up the converted document. This can be used in junction with viewerjs. This request defaults to zip if no type is specified.

Required: `document_id`, `type`

```ruby
BoxView::Document.assets
  document_id: '937778a1a54b4337a5351a78f7188a24',
  type: 'pdf'
```

### Session

#### Create

Generating a document will give you a document id. Next you can create a session using this id. The session will begin the conversion process of the document. When Box is done converting your document it will be available to download through the assets method or the viewer url convenience method. A session expires after a set amount of time. You can set a duration or an expiration date for the session. If left blank, the session is set by box by default to expire in 60 minutes. Duration is marked in minutes. Expiration date is a timestamp. The variable is_downloadable refers to whether or not the box viewer will display a download button or not. If the server response contains the response code `202` then the retry after attribute will be available when calling `BoxView::Session.retry_after`.

After successfully generating a session, the session id will be available. You can either parse it out of the response that is returned, or just call `BoxView.session_id`.

Required: `document_id`

Optional: `duration`, `expiration_date`, `is_downloadable`

```ruby
BoxView::Session.create
  document_id: '937778a1a54b4337a5351a78f7188a24',
  duration: 100,
  expiration_date: (Time.now + 100.minutes),
  is_downloadable: true
```

### Convenience Methods

#### Never Expire

When generating a session if you want your session to last for a very long time (a thousand years) call this method.

```ruby
BoxView::Session.never_expire
```

#### View

Opens a default browser using the viewer url to view a BoxView converted document. Requires a `session_id`.

```ruby
BoxView::Session.view
```

#### ViewerJS URL

This url can be used with viewerjs to display the assets without using the Box iframe or downloading the assets yourself. Requires a `session_id`.

```ruby
BoxView::Session.viewerjs_url
```

#### Viewer URL

The url used in the view method. Can be used in an iframe to display the converted document. Requires a `session_id`.

```ruby
BoxView::Session.viewer_url
```

#### Supported MIMETypes

Returns an array containing all the mimetypes that BoxView is known to support.

```ruby
BoxView::Document.supported_mimetypes
```

#### Supported File Extensions

Returns an array containing all the extensions of filetypes that BoxView is known to support.

```ruby
BoxView::Document.supported_file_extensions
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/boxviewrb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Author

Vincent Taverna, vinny@getlua.com, [vinnymac.github.io](http://vinnymac.github.io)

## License

boxviewrb is available under the MIT license. See the [LICENSE](LICENSE.txt) file for more information.