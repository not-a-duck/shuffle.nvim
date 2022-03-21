import pynvim
from pynvim import Nvim

MAX_S32 = 2147483647

@pynvim.plugin
class DuckShuffle(object):
  # To initialize/update
  # :UpdateRemotePlugins

  default_token: str = " "

  def __init__(self, nvim: Nvim):
    self.nvim = nvim

  @staticmethod
  def parse_parameters(params):
    token = DuckShuffle.default_token
    indices = []
    for a in params:
      try:
        indices.append(int(a) - 1)
      except Exception:
        # conversion to integer failed
        token = a
    return token, indices

  @pynvim.command(
    "DuckShuffle",
    nargs='*',
    range=True,
  )
  def shuffle(self, params, linenumbers):
    token, indices = DuckShuffle.parse_parameters(params)
    start, end = linenumbers
    buffer = self.nvim.current.buffer

    # when the columns of a visual selection are specified, we should also be
    # specific about which things we are going to shuffle.
    _, s_column = buffer.api.get_mark('<')
    _, e_column = buffer.api.get_mark('>')

    # single character column shuffle are hereby explicitly disallowed.
    if not e_column:
      e_column = MAX_S32

    # if we are not dealing with a visual line selection, we should skip up to
    # s_column and starting from e_column in our string splitting shenanigans
    # visual line selection <=> s_column == 0 and e_column == MAX_S32
    # vline_selection = s_column == 0 and e_column == MAX_S32
    # IMPORTANT however! we can generalise this behaviour by treating
    # everything as if they were not visual line selections.

    # we grab the lines and edit them, because when we edit the buffer directly
    # it will show in the undo sequence
    lines = buffer[start-1:end]
    newlines = []

    for line in lines:
      left = line[:s_column]
      middle = line[s_column:e_column+1]
      right = line[e_column+1:]
      split = middle.split(token)
      newline = (
        left
        + token.join([split[i] for i in indices if i < len(split)]) +
        right
      )
      newlines.append(newline)

    buffer[start-1:end] = newlines
