from __future__ import print_function

import stbt
import stbt.audio


def test_match():
    assert stbt.match("videotestsrc-redblue.png")


def test_audio_apis():
    print(stbt.audio.get_rms_volume())
    stbt.audio.wait_for_volume_change()
