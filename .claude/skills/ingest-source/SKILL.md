---
name: ingest-source
description: Ingest a raw source document into the 2Brain wiki — create summary page, concept pages, cross-links, update index and log
---

# Ingest Source into 2Brain Wiki

## When to Use
When a new file has been added to `2Brain/raw/` and needs to be processed into the wiki.

## Steps

1. **Identify the source.** Read the file in `2Brain/raw/` that the user wants to ingest. Read it end to end.

2. **Discuss key takeaways.** Before writing anything to the wiki, summarize the 3-5 most important takeaways and confirm with the user. In autonomous mode, log the takeaways to `2Brain/wiki/log.md` instead.

3. **Create a summary page.** Create `2Brain/wiki/<source-slug>.md` named after the source file. Follow the Wiki Page Format from `2Brain/CLAUDE.md`:
   ```
   # Page Title
   **Summary**: One to two sentences.
   **Sources**: raw/<filename>
   **Last updated**: YYYY-MM-DD
   ---
   Content here.
   ## Related pages
   - [[concept-a]]
   ```

4. **Create or update concept pages.** For each major idea, entity, or concept in the source:
   - If a wiki page exists for that concept, update it with new information
   - If no page exists, create one following the same format
   - A single source may touch 10-15 pages — this is normal

5. **Add cross-links.** Go through all new and updated pages and add `[[wiki-links]]` to connect related concepts.

6. **Update the index.** Edit `2Brain/wiki/INDEX.md` — add new pages with one-line descriptions under the appropriate domain section. Update existing descriptions if the content changed meaningfully.

7. **Log the operation.** Append to `2Brain/wiki/log.md`:
   ```
   YYYY-MM-DD | ingest | source: <filename>, pages created: [list], pages updated: [list]
   ```

8. **Push a summary to Mission Control Knowledge board** so the article is discoverable from the same dashboard used for tasks and approvals. Run:
   ```bash
   /Volumes/BotCentral/Users/milo/repos/OpenClawMaster/tools/scripts/mc-push.sh task \
     --board knowledge \
     --title "<summary page title>" \
     --description "**Summary:** <one-line summary>\n\n**Sources:** <raw/ filename>\n\n**Wiki link:** http://localhost:3200/wiki/<slug>\n\n**Created:** YYYY-MM-DD" \
     --priority medium \
     --status done \
     --field source_agent=ingest
   ```
   This creates a task card in the Knowledge board that links back to the 2Brain wiki viewer at `localhost:3200/wiki/<slug>`.

## Checklist
- [ ] Source file read in full
- [ ] Key takeaways discussed or logged
- [ ] Summary page created in wiki/
- [ ] Concept pages created or updated
- [ ] [[wiki-links]] added throughout
- [ ] INDEX.md updated
- [ ] log.md entry appended
- [ ] Mission Control Knowledge board task created
