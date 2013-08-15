#!/usr/bin/env python
import os
import sys

from os import listdir
from os.path import join

from mutagen.mp3 import MP3
from mutagen.easyid3 import EasyID3

source = '/var/lib/transmission-daemon/downloads/music'
dest = '/home/music/files'

def full_list(directory):
  'Return a directory listing in full'
  return [os.path.join(directory, filename) for filename \
          in os.listdir(directory)]

def recursive_search(directory, extension):
  output = []

  for filename in full_list(directory):
    if os.path.isdir(filename):
      output.extend(recursive_search(filename, extension))
    elif filename.endswith(extension):
      output.append(filename)

  return output

for directory in full_list(source):
  files = recursive_search(directory, '.mp3')

  if not files:
    print 'Skipping empty directory:', directory
    continue

  # Scan each file, and make sure it looks good
  details = None
  loaded = {}

  for filename in files:
    song = MP3(filename, ID3=EasyID3)
    loaded[filename] = song

    if not 'date' in song:
      date = details[2] if details else None
    else:
      date = song['date'][0][:4]

    song_details = (
        song['artist'][0],
        song['album'][0],
        date
      )

    if not details:
      details = song_details
    elif song_details != details:
      print 'Song details', song_details, 'does not match previous', details
      continue
    
  (artist, album, year) = details

  # Some basic neatening (special charectars)
  artist = artist.replace(' & ', ' and ')

  # Format the name according to available pieces
  name = '%s - %s' % (artist, album)

  if not year:
    print '[WARN] Album missing year:', directory
  else:
    name += ' [%s]' % year

  # Pull out the preloaded
  folder = os.path.join(dest, 'Albums', name)

  if not os.path.isdir(folder):
    os.makedirs(folder)

  for filename in files:
    song = loaded[filename]

    if not 'tracknumber' in song:
      print 'Song missing tracknumber:', filename
      continue

    # Get the actual track number
    track = int(song['tracknumber'][0].split('/')[0])
    title = song['title'][0]

    title = title.replace('/', '-')

    result = os.path.join(folder,
      '%02d - %s.mp3' % (track, title)
    )
    if os.path.islink(result):
      os.unlink(result)

    try:
      os.symlink(filename, result)
    except:
      print repr(filename), repr(result)

  

  print details

