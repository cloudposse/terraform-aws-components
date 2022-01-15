#!/bin/bash

# NOTE: This script should be executed from the root of the repository.
# NOTE: This script is only supported on GNU/Linux.
tmp_doc_file="/tmp/rebuild-mixins-docs.tmp.md"
mixins_dir="mixins"

readme_lead='^<!-- BEGINNING OF TERRAFORM-MIXINS DOCS HOOK -->$'
readme_tail='^<!-- END OF TERRAFORM-MIXINS DOCS HOOK -->$'
tf_lead='^# <-- BEGIN DOC -->$'
tf_tail='^# <-- END DOC -->$'

# Insert content between markers in README.md
for file in $(ls -1 ${mixins_dir} | grep .mixin.tf); do
	printf "## \`${file}\`\n"
	# below: read between tf_lead and tf_tail; delete tf_lead; delete tf_tail; remove #; remove leading whitespace; print
	sed -n "/$tf_lead/,/$tf_tail/ {/$tf_lead/d;/$tf_tail/d; s/#//g; s/^[ \t]*//; p; }" "${mixins_dir}/${file}"
done >> ${tmp_doc_file}

sed -e "/$readme_lead/,/$readme_tail/{ /$readme_lead/{p; r ${tmp_doc_file}
	}; /$readme_tail/p; d }" mixins/README.md # intentional newline (sed will otherwise complain about unmatched curly braces)

rm ${tmp_doc_file}
