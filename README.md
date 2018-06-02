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
otherwise you RISK looing data. Consider yourself warned!
