import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RegistroProyectoContenedor } from './registro-proyecto-contenedor';

describe('RegistroProyectoContenedor', () => {
  let component: RegistroProyectoContenedor;
  let fixture: ComponentFixture<RegistroProyectoContenedor>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RegistroProyectoContenedor]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RegistroProyectoContenedor);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
