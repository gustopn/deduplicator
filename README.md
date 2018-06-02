# deduplicator
A shell script that deduplicates files on a filesystem

Here we have a deduplicator shell script that deduplicates files with same content.
There are some limitations with this script. I created it for myself to solve my problem,
so it might not be the right solution for anyone. I use to have my data on a separate
filesystem that is "owned" by my userid. For this script to work properly this has to be the case.
Even though it can work even without proper permissions set,
it will just fail to remove data it has no permissions to.

The script does not do any writing except a sum file that it stores on the root of the
filesystem that is being deduplicated.

Then we have a very sensible part of the script where it does take 2 file pathnames,
checks if they have different inodes (that's why this only works on same filesystem),
and if they have different inode numbers it goes into "cmp" to check if the two files
are different. If they are not diffrent (so being the same) it removes the second file.
And that is being done also for a list of files.

Take care there and be sure that the part where files are removed is working properly,
otherwise you RISK loosing data. Consider yourself warned!

# empty dirs remover
Yes, after deduplication there will be lots of empty dirs on the filesystem,
so I also wrote a script that removes those. This is also in the good-enough quality.

# use case
This script was tested, on my files. It is however only effective with big files, like
large numbers of media files. And even there it could be optimized a lot (especially 
where it checks 2 files against each other - with "cmp" command, is very innefective
on HDDs - does not apply to SSDs).

I deduplicated 1.4T out of 7.3T filesystem using this script. So this is no joke.

# bugs
Maybe, but first of all there is a lot of room for improvement. I know. ;-)
It just happened to be good enough for me. However, I am planning to improve
on the shortcommings I know well of as soon as I have time for it.

# limitations
Currently this script only works on GNU/Linux since it is dependent on GNU
userland for tools used. In future it would be desirable to make it compatible
with other operating system userlands. That's one of the more shortcommings
of this script I know well of.