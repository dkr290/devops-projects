- version 10.951

You can also set manually which emotion you expect with [] tags, here is one example for one speaker:

```

[fear] At the very beginning I was so afraid to speak.
[sadness] Nobody would talk to me. I felt so alone.
[disgust] They would just ignore me and pretend that I didnt exist
[happy] By chance I discovered this wonderful App, and now everything is different.
[anger] I have a new voice and now everybody will have no choice but to listen to my words !!!
```

You can mix emotions [sadness,disgust] or if you want to precise the weight of one or several emotions [sadness=0.7,disgust] (in any case total of weights is 1)

Remember two speakers mode requires to insert "Speaker 1:" & "Speaker 2:" to indicate who is talking.

There is only one snag: Index TTS 2 supports only English & Chinese. But dont' panic ! not all is lost. There is a workaround:

Feed Index TTS 2 with the voice to clone and ask it to generate a sample English spoken text with with the emotion you expected
Now ask Qwen3TTS, to clone this newly generated voice sample (in English) in the other language you want
