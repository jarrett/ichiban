Put PDFs, PPTs, and whatever other miscellaneous asset files here. Paths in this folder map to paths
in the compiled folder. For example, assets/about_us.pdf would be copied to compiled/about_us.pdf.

Remember that everything you put here will be checked into git. If you're deploying with Capistrano,
a large repository will slow down your deployment. For this reason, and for better download times
for your users, it's often better to host your large asset files on a CDN instead.