---
title: How do I model a link and its label text to an external website?
priority: 2
category: Modeling
---

### Problem Statement:

Within the AAC data there are links to existing websites, such as the institution's collections site, wikipedia article about the party, or other human-readable resources that exist at URLs. 

What is the RDF pattern that indicates a link to the website as well as metadata about that link, such as a title?

### Best Practice:

AAC best practice for this is to use the `foaf` ontology to model these links.  If the link is to the *primary* website associated with an entity, it should be modeled using `foaf:homepage`, and given an explicit label:

    _:art_object foaf:homepage <www.institution.org/objects/art_object>.
    <www.institution.org/objects/art_object> rdfs:label "Homepage for Art Object".

If it is merely a page *about* an object, use `foaf:page`:

    _:art_object foaf:page <www.institution.org/objects/art_object>.
    <www.institution.org/objects/art_object> rdfs:label "Homepage for Art Object".

If you wish to make explicit statements about the page itself, including the creator of the page, why it is linked, or anything else, model the webpage as a `E31 Document` and type it with the appropriate AAT type. 


### Discussion:

Use Case: How do I go from the AAC data about an object back to the collections page on the institution website?

Also, I'm happy to foaf:page it up here, but that only handles the link, not the *text of the link*.  As in, for <a href="URL">LINK TEXT</a>, I can get the URL, but how do I get the LINK TEXT?


*(From Rob)*

Use case?  That said, the foaf or schema equivalents seem much better to me than the very very loose p1 and p48

*(From Rob, via email, 9/19/2016)*

I think the outstanding question is the text for the link?  This seems to be straying very much into presentation issues, rather than semantic description of a resource. If there needs to be a URI associated with a context-specific label, it would need its own resource.  The current foaf:page, foaf:homepage seem good recommendations to me. Potentially the schema.org equivalents if we have other schema predicates to import and want to cut down the number of ontologies.

*(From David, via email, 9/19/2016)*

The real question here is making sure that the URLs to the websites don't get turned into p1_has_identifier to a E42_Identifier with no additional semantics, which is what is currently happening in the mappings.  The secondary concern for me (which may not get addressed) is being able to figure out why and how the URLs are associated with the entity, since they are unlikely to have that information available at the end source.  If we don't get it, I'm just going to be able to provide a list of "Related URLs":  what I'd like to be able to do is provide "Institution Page: <link to YCBA>" and "External Resources:  <Link to Wikipedia>, <Link to artist homepage>".   But to do that I need some sort of hook.

*(David)* 

The pattern I'm seeing emitted from the AAC mappings is:

    _:entity crm:P1_is_identified_by _:url.
    _:url a crm:E42_Identifier;
        crm:p3_has_note "url as a string".

See <https://github.com/american-art/autry/issues/28> for an example.  
If we're going to do this, I would strongly recommend typing these with

    _:url crm:p2_has_type <http://vocab.getty.edu/aat/300404630>.

It does seem odd to treat a URL as a string, though.    Additionally, just saying it's a identifier and typing it does not provide the context that it's the a URL that represents a human-readable description of the entity—it just says that it's something with a specific form.  This means that it would show up in the list of identifiers, but that the browse application would not have the ability to present those URLs to a viewer with any specific semantic value.

### CRM Variant

*Vladimir 12/14/2016*: I'm fine with the foaf:homepage variant. 
For completeness, here's how to represent this in CRM:

```turtle
_:art_object
  crm:P70i_is_documented_in <http://www.institution.org/objects/art_object>.
<http://www.institution.org/objects/art_object> a crm:E31_Document;
  crm:P2_has_type aat:300264578; # webpage
  crm:P3_has_note "Homepage for Art Object".
```
Note that the object of `foaf:homepage` is a `foaf:Document`: it doesn't specify anywhere it's a webpage.
The CRM variant says that with P2.

### Reference:


