# myexpand
`myexpand` is a custom implementation of the shell command `expand`.
Thus, myexpand converts all tabs contained in a given text to spaces.

* Programming language: C
* University Lecture: Operating Systems 

## Usage
First, compile using `make`.

Then, you can use it just as the regular `expand` command:
- `./myexpand [-t tabstops] [file ...]`
- reading from stdin is also possible, e.g. just `./myexpand` or `cat test.txt | ./myexpand`

Run `make clean` to remove compiled sources.
