import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RegistroProyecto } from './registro-proyecto';

describe('RegistroProyecto', () => {
  let component: RegistroProyecto;
  let fixture: ComponentFixture<RegistroProyecto>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RegistroProyecto]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RegistroProyecto);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
