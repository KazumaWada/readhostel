//https://github.com/hotwired/stimulus-rails?tab=readme-ov-file#with-import-map

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
//lazyLoadControllersFromこっちにすると、呼ばれるまでloadされないから軽くなる(https://github.com/hotwired/stimulus-rails?tab=readme-ov-file#usage-with-import-map)