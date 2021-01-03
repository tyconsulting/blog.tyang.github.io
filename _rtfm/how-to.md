# How To?

## Add Links to Sidebar

modify:

* _config.yml
* index.html

```markdown
sidebar:
- text: "[![your logo](/assets/images/logo.png)](http://home.page.org)"
- title: "Some Optional Title"
text: "Some optional text here."
```
Reference: [https://github.com/mmistakes/minimal-mistakes/issues/1869](https://github.com/mmistakes/minimal-mistakes/issues/1869)

## Start ordered list from number other than 1

```markdown
1. First

Some text and other stuff

{:start="2"}
2. Second

Othe stuff
```

Reference: [https://stackoverflow.com/questions/48612358/how-to-start-ordered-list-from-number-other-then-1-in-jekyll](https://stackoverflow.com/questions/48612358/how-to-start-ordered-list-from-number-other-then-1-in-jekyll)

## Embed YouTube Video

```html
<iframe src="//www.youtube.com/embed/youtube-vid-id" height="375" width="640" allowfullscreen="" frameborder="0"></iframe>
```

## Icons

* [Font Awesome](https://fontawesome.com/icons?d=gallery)

## Adding Header image

```markdown
excerpt: ""
header:
  overlay_image: # image-relative-path i.e. /wp-content/uploads/2015/06/OpsMgrExnteded-banner.png
  overlay_filter: 0.5 # same as adding an opacity of 0.5 to a black background
```