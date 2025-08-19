import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { Header } from "./header/header";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']  // fijarse que es styleUrls, plural
  ,
  imports: [RouterOutlet, Header]
})
export class AppComponent {
  title = 'frontend';
}
