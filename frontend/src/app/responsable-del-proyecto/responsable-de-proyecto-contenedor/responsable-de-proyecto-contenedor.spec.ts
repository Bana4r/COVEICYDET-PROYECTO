import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ResponsableDeProyectoContenedor } from './responsable-de-proyecto-contenedor';

describe('ResponsableDeProyectoContenedor', () => {
  let component: ResponsableDeProyectoContenedor;
  let fixture: ComponentFixture<ResponsableDeProyectoContenedor>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ResponsableDeProyectoContenedor]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ResponsableDeProyectoContenedor);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
