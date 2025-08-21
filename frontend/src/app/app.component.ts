import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']  // fijarse que es styleUrls, plural
  ,
  imports: [RouterOutlet]
})
export class AppComponent {
  title = 'frontend';
}
