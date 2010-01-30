function set_removers() {
	$$('.remove_element').each(function(link){
		link.addEvent('click', function(ev) {
			link.getParent().destroy()
		})
	})
}

window.addEvent('domready', function() {
	$$('.add_field_set').each(function(link){
		link.addEvent('click', function(ev) {
			var fieldset = link.getNext('fieldset')
			var next = fieldset.clone()
			next.getElements('input').each(function(input) {
				input.set('value', '')
			})
			next.getElements('option').each(function(input) {
				input.set('selected', false)
			})
			next.getElements('.remove_element').each(function(remover) {
				remover.removeClass('hidden')
			})
			next.inject(fieldset, 'after')
			set_removers()
		})
	})
	
	set_removers()
});